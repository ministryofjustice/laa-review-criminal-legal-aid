apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-worker-staging
  namespace: laa-review-criminal-legal-aid-staging
spec:
  replicas: 2
  revisionHistoryLimit: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 50%
      maxSurge: 100%
  selector:
    matchLabels:
      app: review-criminal-legal-aid-worker-staging
  template:
    metadata:
      labels:
        app: review-criminal-legal-aid-worker-staging
        tier: worker
        metrics-target: laa-review-criminal-legal-aid-staging-metrics-target
    spec:
      containers:
      - name: worker
        image: ${ECR_URL}:${IMAGE_TAG}
        imagePullPolicy: Always
        ports:
          - containerPort: 9394
        command: ["bundle", "exec", "sidekiq"]
        resources:
          requests:
            cpu: 10m
            memory: 512Mi
          limits:
            cpu: 500m
            memory: 1Gi
        readinessProbe:
          exec:
            command:
              - cat
              - tmp/sidekiq_process_has_started_and_will_begin_processing_jobs
          periodSeconds: 10
          failureThreshold: 3
        livenessProbe:
          exec:
            command:
              - /bin/sh
              - -c
              - pgrep -f sidekiq
          failureThreshold: 30
          periodSeconds: 3
        startupProbe:
          exec:
            command:
              - /bin/sh
              - -c
              - pgrep -f sidekiq
          failureThreshold: 60
          periodSeconds: 5
        envFrom:
          - configMapRef:
              name: configmap-staging
          - secretRef:
              name: laa-review-criminal-legal-aid-secrets
        env:
          - name: DATABASE_URL
            valueFrom:
              secretKeyRef:
                name: rds-instance
                key: url
          - name: DATASTORE_API_AUTH_SECRET
            valueFrom:
              secretKeyRef:
                name: datastore-api-auth-secret
                key: secret
          - name: REDIS_URL
            valueFrom:
              secretKeyRef:
                name: ec-cluster-output
                key: url
          - name: REDIS_AUTH_TOKEN
            valueFrom:
              secretKeyRef:
                name: ec-cluster-output
                key: auth_token
          - name: AWS_S3_BUCKET
            valueFrom:
              secretKeyRef:
                name: s3-bucket
                key: bucket_name
