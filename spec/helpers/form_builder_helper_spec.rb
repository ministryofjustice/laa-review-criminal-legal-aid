require 'rails_helper'

RSpec.describe FormBuilderHelper do
  let(:form_object) { class_double(Class) }

  let(:builder) do
    GOVUKDesignSystemFormBuilder::FormBuilder.new(
      :object_name,
      form_object,
      self,
      {}
    )
  end

  describe '#continue_button' do
    before do
      # stub_const('FormObject', form_object)
      allow(builder).to receive(:show_secondary_button?).and_return(draftable)
    end

    context 'with an application that cannot be drafted' do
      let(:draftable) { false }
      let(:expected_markup) do
        '<button type="submit" formnovalidate="formnovalidate" class="govuk-button" data-module="govuk-button" ' \
          'data-prevent-double-click="true">Save and continue</button>'
      end

      it 'outputs only the continue button' do
        expect(
          builder.continue_button
        ).to eq(expected_markup)
      end
    end

    context 'with an application that can be drafted' do
      let(:draftable) { true }
      let(:expected_markup) do
        '<div class="govuk-button-group"><button type="submit" formnovalidate="formnovalidate" class="govuk-button" ' \
          'data-module="govuk-button" data-prevent-double-click="true">Save and continue</button>' \
          '<button type="submit" formnovalidate="formnovalidate" class="govuk-button govuk-button--secondary" ' \
          'data-module="govuk-button" data-prevent-double-click="true" name="commit_draft">Save and come back later' \
          '</button></div>'
      end

      it 'outputs the continue button together with a save draft button' do
        expect(
          builder.continue_button
        ).to eq(expected_markup)
      end
    end
  end
end
