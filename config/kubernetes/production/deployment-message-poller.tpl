apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-message-poller-production
  namespace: laa-review-criminal-legal-aid-production
spec:
  replicas: 1
  revisionHistoryLimit: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 50%
      maxSurge: 100%
  selector:
    matchLabels:
      app: review-criminal-legal-aid-message-poller-production
  template:
    metadata:
      labels:
        app: review-criminal-legal-aid-message-poller-production
        metrics-target: laa-review-criminal-legal-aid-production-metrics-target
    spec:
      serviceAccountName: laa-review-criminal-legal-aid-production-service
      terminationGracePeriodSeconds: 40
      containers:
      - name: message-poller
        image: ${ECR_URL}:${IMAGE_TAG}
        imagePullPolicy: Always
        command: ["bin/message_poller"]
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
              - tmp/poller_ready
          periodSeconds: 10
          failureThreshold: 4
        livenessProbe:
          exec:
            command:
              - /bin/sh
              - -c
              - pgrep -f "rails runner"
          failureThreshold: 30
          periodSeconds: 3
        startupProbe:
          exec:
            command:
              - /bin/sh
              - -c
              - pgrep -f "rails runner"
          failureThreshold: 60
          periodSeconds: 5
        envFrom:
          - configMapRef:
              name: configmap-production
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
          - name: SQS_QUEUE
            valueFrom:
              secretKeyRef:
                name: application-events-queue
                key: sqs_name
