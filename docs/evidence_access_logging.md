# Evidence Access Logging

## Overview

This logging system captures caseworker evidence viewing and downloading events in a structured format optimized for OpenSearch queries.

## Log Events

Two event types are logged:

- `evidence_viewed` - When a caseworker views a file inline
- `evidence_downloaded` - When a caseworker downloads a file

## Log Format

Each event is logged with a searchable event name followed by a JSON object:

```
evidence_viewed {"application_id":"12345","caseworker_id":"user_456","caseworker_role":"caseworker","assigned":"assigned","file_type":"application/pdf","timestamp":"2024-01-15T10:30:00Z"}
```

## Logged Fields

| Field             | Description                                   | Example Values                                                |
| ----------------- | --------------------------------------------- | ------------------------------------------------------------- |
| `application_id`  | Crime application ID                          | `"12345"`                                                     |
| `caseworker_id`   | User ID of the caseworker                     | `"user_456"`                                                  |
| `caseworker_role` | Role of the caseworker                        | `"caseworker"`, `"supervisor"`, `"data_analyst"`, `"auditor"` |
| `assigned`        | Whether caseworker is assigned to application | `"assigned"`, `"not_assigned"`                                |
| `file_type`       | MIME type of the file                         | `"application/pdf"`, `"image/jpeg"`                           |
| `timestamp`       | ISO 8601 timestamp                            | `"2024-01-15T10:30:00Z"`                                      |

## OpenSearch Query Examples

### Basic Stats: View vs Download Ratio

```json
{
  "query": {
    "bool": {
      "should": [
        { "match": { "message": "evidence_viewed" } },
        { "match": { "message": "evidence_downloaded" } }
      ]
    }
  },
  "aggs": {
    "by_action": {
      "terms": {
        "field": "message.keyword",
        "include": ["evidence_viewed", "evidence_downloaded"]
      }
    }
  }
}
```

### Filter by Role

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "message": "evidence_viewed" } },
        { "match": { "message": "caseworker_role\":\"supervisor" } }
      ]
    }
  }
}
```

### Filter by Assignment Status

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "message": "evidence_downloaded" } },
        { "match": { "message": "assigned\":\"not_assigned" } }
      ]
    }
  }
}
```

### Count Downloads by File Type

```json
{
  "query": {
    "match": { "message": "evidence_downloaded" }
  },
  "aggs": {
    "by_file_type": {
      "terms": {
        "script": {
          "source": "def m = /file_type\":\"([^\"]+)/.matcher(doc['message.keyword'].value); m.find() ? m.group(1) : 'unknown'"
        }
      }
    }
  }
}
```

### Activity by Caseworker

```json
{
  "query": {
    "bool": {
      "should": [
        { "match": { "message": "evidence_viewed" } },
        { "match": { "message": "evidence_downloaded" } }
      ]
    }
  },
  "aggs": {
    "by_caseworker": {
      "terms": {
        "script": {
          "source": "def m = /caseworker_id\":\"([^\"]+)/.matcher(doc['message.keyword'].value); m.find() ? m.group(1) : 'unknown'"
        }
      }
    }
  }
}
```

### Time-based Analysis

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "message": "evidence_viewed" } },
        { "range": { "@timestamp": { "gte": "now-7d" } } }
      ]
    }
  },
  "aggs": {
    "views_over_time": {
      "date_histogram": {
        "field": "@timestamp",
        "calendar_interval": "day"
      }
    }
  }
}
```
