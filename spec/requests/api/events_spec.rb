require 'rails_helper'
require 'base64'

RSpec.describe 'Api::Events' do
  include_context 'with review'

  let(:sns_message_id) { SecureRandom.uuid }
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  let(:message) do
    {
      event_name: 'apply.submission',
      data: {
        id: application_id,
        submitted_at: DateTime.parse('2022-10-27T14:09:11'),
        parent_id: nil
      }
    }
  end

  def do_request
    post('/api/events', params: body.to_json, headers: headers)
  end

  def private_key_string
    <<-KEY
    MIIEowIBAAKCAQEAtVx6zAEpZZXTpTO4PP36DzPw9Xa2T1fIWFI2P3TWODq99Z44
    aMYhxZS0X7PmzvurK3pa4s4tBp6fxL6gSSbX97s8Q2xNqgJilJZ5s6JMNfclRL15
    8dUJq3UhGxFv/WGwgfEXUUT6nZ8tK3jzc6CiHsB/9leEENKbbk1P59m40LqGker1
    J4eytexuLx1jBEFqzAAd6bU0i07S+kZy2Nxugjn+1xkfTYbhZs93wJGuclm8ROlE
    GUHJ8U/4ZuQVOm8mbmTxvA0Y6EtvunjIcAW4UnNkeTDOLvccgCUpo3kfykWK04ch
    pj+TCXv5KTViSLpENNQUwXZngOA1ZR2hlx+ONQIDAQABAoIBAFwPZJn3oP7a7gM2
    3LfBKFTdRdwj9WkTIzSKDtVpRnBmiRSLyxCMOopj8Kd/15KLt5irVEU66SoqDOm+
    5fgcCpbK6U1ERawd59KLC53+rXbbTIS3NZZnULBDFZn64QEavJFJQ0/SlvC54yDl
    FZdFG+ZGSu5OAFDVx2ZXQk9remAg4pehIa/DzIAe3P9VaqLvhP/Z72cynpAp+4cO
    JrhZCXXpdDHYvDo3ccAkLWjl7JqofNLNm5rwDO5yy+kV3BFLQzr+F0kspq1ImeGK
    2a+w1+QzdEOT9dL3FM8UDuKPsJUWGnB8tCK0UmfvAQBabl1nLaju8+nbGLT7P+pp
    eDNP+KUCgYEA8Sq7YbCmL1zliknZafvcUdZBDLcYL6cvDDFUGTTBPWy3t3zv3lOI
    jiAEykOC2N0JP/CcTsBNWHCK4MlK5ciU5Xgg8JkkLi+JfDRIytOLJcxahXMUhSXt
    VGi+/CZRgx5YokZ/ROUMO77WzuEay79Y9/mFd5J0ON0L2OqDE9j/PicCgYEAwIQV
    eJnQW7HGL+aSDq9IL8v6CM8NHGL2N2vEP8/NVP+Z2zkYTOuHXxOeUVI3L0Z9l4W1
    ew6a+omNZgQxrqOvU0RkyMoLekk2P9B8328KpbFH1QUL+8haJT/ohW0ZDx42AIxM
    bjNfVZDcnEMLciGip1H6/3ZCZS8JwIsvJT3zpkMCgYBVyO1+gmea0WCVIE/F82Eb
    eysIatifmsiRfbp8fNeAEfwHuNlaLDyW0azihcE1guqXY+811BGvM9kyvGd39TGB
    romJC/BivWYaWD7MZxNIDrjkX1sdQbB6JghJiRfVnCXLE2iSCSeg2PFwBYKSly3+
    hzOCpQXSdE6Sili15qpkYQKBgHvT+aOK/BQesuWYnxXG9N2ZjAgidcJufQSE0sRg
    uygTCDmT7ed8D6S+D7Uq9sf3xUyy+lpeuJyx4TtfMz2rl1gtw83K97r+YGCHj+p/
    mA+fih6gkmavJhyTkNJRrC6nNgEAPSEc9hMpjF0OWsxciiypdJLg1DAVI2avn/GK
    ea/VAoGBAOb7Ap6UQGeNU2G+pmI44ljSvzbpZamSvbXOx+OG3zBiG5qRxE66VasQ
    ItSPyzISlrImu33sZTjsG1VR1kjAAWog6MPd4coQ+VPOSLduJ2BSmn51g/5obmSb
    QokDfdmcZIGphkeX1hIgcy1yDlbaa8oodadp8A2YQvBzFb8EGk5O
    KEY
  end

  def public_key
    File.read(Rails.root.to_s + '/spec/fixtures/files/certs/certificate.pem')
  end

  def public_key_string
    <<-CERT
    -----BEGIN CERTIFICATE-----
    MIIDmDCCAoACCQCuLCz91lM4SzANBgkqhkiG9w0BAQsFADCBjTELMAkGA1UEBhMC
    R0IxEDAOBgNVBAgMB0VOR0xBTkQxDzANBgNVBAcMBkxPTkRPTjEMMAoGA1UECgwD
    TU9KMQwwCgYDVQQLDANMQUExHDAaBgNVBAMME3Rlc3RpbmcubGFhLm1vai5jb20x
    ITAfBgkqhkiG9w0BCQEWEnRlc3RpbmdsYWFAbW9qLmNvbTAeFw0yMzA0MDQwOTQ5
    NTBaFw0yNDA0MDMwOTQ5NTBaMIGNMQswCQYDVQQGEwJHQjEQMA4GA1UECAwHRU5H
    TEFORDEPMA0GA1UEBwwGTE9ORE9OMQwwCgYDVQQKDANNT0oxDDAKBgNVBAsMA0xB
    QTEcMBoGA1UEAwwTdGVzdGluZy5sYWEubW9qLmNvbTEhMB8GCSqGSIb3DQEJARYS
    dGVzdGluZ2xhYUBtb2ouY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
    AQEAtVx6zAEpZZXTpTO4PP36DzPw9Xa2T1fIWFI2P3TWODq99Z44aMYhxZS0X7Pm
    zvurK3pa4s4tBp6fxL6gSSbX97s8Q2xNqgJilJZ5s6JMNfclRL158dUJq3UhGxFv
    /WGwgfEXUUT6nZ8tK3jzc6CiHsB/9leEENKbbk1P59m40LqGker1J4eytexuLx1j
    BEFqzAAd6bU0i07S+kZy2Nxugjn+1xkfTYbhZs93wJGuclm8ROlEGUHJ8U/4ZuQV
    Om8mbmTxvA0Y6EtvunjIcAW4UnNkeTDOLvccgCUpo3kfykWK04chpj+TCXv5KTVi
    SLpENNQUwXZngOA1ZR2hlx+ONQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQAfv+dQ
    UTHkUstgThw4ptVt+JI9JSZejHmUgy/eML1aM7GFFU/rfwwN51uAEk5ROnx0awfD
    hs4wqoEdfjqh1z+AorvL6e8IzX0YRJCbo0HZpY2ZVbomJDrHH7wNoqqEE4vgB/br
    fDgVNhkaI//idFtfYhqVeZY67p6MLrSKde3I5V+xBOQ2ilQGqSo9/gwi8uxuGo9u
    6U8dhmTTnz4XZbGFWWRzzyns2HLwv/cgQDHJ75GNOFxw9ZLjxIRdZx+QayzTqseF
    qYGkpHKlNGbBUizeRYyVBDJOSH3Mi78pVyotUFGU2wTtyUtotxxZFmMr/bc/1Caa
    vlcqrvSNPc8OC3nX
    -----END CERTIFICATE-----
    CERT
  end

  before do
    stub_request(:get, 'https://sns.us-west-2.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem').with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Ruby'
      }
    ).to_return(status: 200, body: public_key, headers: {})

    # stub_request(:get, 'https://sns.us-west-2.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem').with(
    #   headers: {
    #     'Accept' => '*/*',
    #     'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    #     'User-Agent' => 'Ruby'
    #   }
    # ).to_return(status: 200, body: '', headers: {})
  end

  describe 'SNS signing mechanism' do
    it 'signs the message body' do
      message_body = <<-DOC
        Message
        #{message.to_json}
        MessageId
        #{sns_message_id}
        Subject
        apply.submission
        Timestamp
        2012-05-02T00:54:06.655Z
        Type
        Notification
      DOC

      puts "MessageBody: #{message_body}"

      # raw = File.read "cert.cer" # DER- or PEM-encoded
      # certificate = OpenSSL::X509::Certificate.new raw


      key = File.read(Rails.root.to_s + '/spec/fixtures/files/certs/key.pem')
      #path = '/Users/mohammed.seedat/development-meta/vs-code-workspaces/key.pem'
      private_key = OpenSSL::PKey::RSA.new(key)
      signature = private_key.sign(OpenSSL::Digest::SHA1.new, message_body)
      base64_signature = Base64.encode64(signature)
      puts base64_signature
    end
  end

  describe 'SNS Nofification callback' do
    let(:headers) do
      {
        'x-amz-sns-message-type' => 'Notification',
        'x-amz-sns-message-id' => sns_message_id
      }
    end

    let(:body) do
      {
        'Type' => 'Notification',
        'MessageId' => sns_message_id,
        'TopicArn' => 'arn:aws:sns:us-west-2:123456789012:MyTopic',
        'Subject' => 'apply.submission',
        'Message' => message.to_json,
        'Timestamp' => '2012-05-02T00:54:06.655Z',
        'SignatureVersion' => '1',
        #'SigningCertURL' => 'https://sns.us-west-2.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem',
        'SigningCertURL' => 'http://localhost:3005/certs/certificate.pem',
        'UnsubscribeURL' => 'https://sns.us-west-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-west-2:123456789012:MyTopic:c9135db0-26c4-47ec-8998-413945fb5a96'
      }
    end

    it 'creates an ApplicationReceived event' do
      message_body = <<-DOC
        Message
        #{body['Message']}
        MessageId
        #{body['MessageId']}
        Subject
        #{body['Subject']}
        Timestamp
        #{body['Timestamp']}
        Type
        #{body['Type']}
      DOC

      puts "MessageBody: #{message_body}"

      # raw = File.read "cert.cer" # DER- or PEM-encoded
      # certificate = OpenSSL::X509::Certificate.new raw


      key = File.read(Rails.root.to_s + '/spec/fixtures/files/certs/key.pem')
      #path = '/Users/mohammed.seedat/development-meta/vs-code-workspaces/key.pem'
      private_key = OpenSSL::PKey::RSA.new(key)
      signature = private_key.sign(OpenSSL::Digest::SHA1.new, message_body)
      base64_signature = Base64.encode64(signature)
      puts base64_signature
      body['Signature'] = base64_signature

      expect { do_request }.to change { review.state }.from(nil).to(:open)

      expect(response).to have_http_status :created
    end

    it 'is idempotent' do
      do_request
      expect { do_request }.not_to(change { review.state })

      expect(response).to have_http_status :ok
    end
  end

  describe 'SNS Nofification callback with raw_message_delivery' do
    let(:headers) do
      {
        'x-amz-sns-message-type' => 'Notification',
        'x-amz-sns-message-id' => sns_message_id,
        'x-amz-sns-rawdelivery' => 'true'
      }
    end

    let(:body) { message.to_json }

    it 'creates an ApplicationReceived event' do
      expect { do_request }
        .to change { review.state }.from(nil).to(:open)
        .and change { review.submitted_at }.from(nil).to DateTime.parse('2022-10-27T14:09:11')

      expect(response).to have_http_status :created
    end
  end

  describe 'SNS Subscription Confirmation' do
    let(:headers) do
      {
        'x-amz-sns-message-type' => 'SubscriptionConfirmation',
        'x-amz-sns-message-id' => sns_message_id
      }
    end

    let(:body) do
      {
        'Type' => 'SubscriptionConfirmation',
        'MessageId' => sns_message_id,
        'Token' => '2336412f37f...',
        'TopicArn' => 'arn:aws:sns:us-west-2:123456789012:MyTopic',
        'Message' => 'You have chosen to subscribe to the topic arn:aws:sns:us-west-2:123456789012:MyTopic.',
        'SubscribeURL' => 'https://sns.us-west-2.amazonaws.com/?Action=ConfirmSubscription&TopicArn=arn:aws:sns:us-west-2:123456789012:MyTopic&Token=2336412f37',
        'Timestamp' => '2012-04-26T20:45:04.751Z',
        'SignatureVersion' => '1',
        'Signature' => 'EXAMPLEpH+...',
        'SigningCertURL' => 'https://sns.us-west-2.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem'
      }.to_json
    end

    it 'confirms the subscription' do
      stub = stub_request(:get, 'https://sns.us-west-2.amazonaws.com/?Action=ConfirmSubscription&Token=2336412f37&TopicArn=arn:aws:sns:us-west-2:123456789012:MyTopic').to_return(
        status: 200, body: '', headers: {}
      )

      do_request
      expect(stub).to have_been_requested
      expect(response).to have_http_status :ok
    end
  end

  describe 'SNS unsubscribe notifcation' do
    let(:headers) do
      {
        'x-amz-sns-message-type' => 'UnsubscribeConfirmation',
        'x-amz-sns-message-id' => sns_message_id
      }
    end

    let(:body) do
      {
        'Type' => 'UnsubscribeConfirmation'
      }
    end

    it 'returns okay' do
      do_request
      expect(response).to have_http_status :ok
    end
  end
end
