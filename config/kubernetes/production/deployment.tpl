apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-production
  namespace: laa-review-criminal-legal-aid-production
spec:
  replicas: 4
  revisionHistoryLimit: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 50%
      maxSurge: 100%
  selector:
    matchLabels:
      app: review-criminal-legal-aid-web-production
  template:
    metadata:
      labels:
        app: review-criminal-legal-aid-web-production
        tier: frontend
        metrics-target: laa-review-criminal-legal-aid-production-metrics-target
    spec:
      serviceAccountName: laa-review-criminal-legal-aid-production-service
      containers:
      - name: webapp
        image: ${ECR_URL}:${IMAGE_TAG}
        imagePullPolicy: Always
        ports:
          - containerPort: 3000
          - containerPort: 9394
        resources:
          requests:
            cpu: 25m
            memory: 1Gi
          limits:
            cpu: 500m
            memory: 3Gi
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
            httpHeaders:
              - name: X-Forwarded-Proto
                value: https
              - name: X-Forwarded-Ssl
                value: "on"
          initialDelaySeconds: 11
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /ping
            port: 3000
            httpHeaders:
              - name: X-Forwarded-Proto
                value: https
              - name: X-Forwarded-Ssl
                value: "on"
          failureThreshold: 1
          periodSeconds: 10
        startupProbe:
          httpGet:
            path: /ping
            port: 3000
            httpHeaders:
              - name: X-Forwarded-Proto
                value: https
              - name: X-Forwarded-Ssl
                value: "on"
          failureThreshold: 20
          periodSeconds: 10
        envFrom:
          - configMapRef:
              name: configmap-production
          - secretRef:
              name: laa-review-criminal-legal-aid-secrets
        env:
          # secrets created by terraform
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
