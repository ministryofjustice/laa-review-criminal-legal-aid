# Evidence Access Logging

## Overview

This logging system captures caseworker evidence viewing and downloading events in a structured format optimized for OpenSearch queries.

## Log Events

Two event types are logged:

- `evidence_viewed` - When a caseworker views a file inline
- `evidence_downloaded` - When a caseworker downloads a file

## Log Format

Each event is logged with a searchable event name followed by a JSON object:

```json
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

### Simple Test Query - Verify Logs Exist

First, verify evidence logs are being captured:

```json
{
  "size": 5,
  "query": {
    "bool": {
      "must": [
        {
          "term": {
            "kubernetes.namespace_name.keyword": "laa-review-criminal-legal-aid-production"
          }
        },
        { "match": { "log": "evidence_downloaded" } },
        { "range": { "@timestamp": { "gte": "now-7d" } } }
      ]
    }
  },
  "_source": ["log", "@timestamp"]
}
```

### Basic Stats: View vs Download Ratio

```json
{
  "size": 0,
  "query": {
    "bool": {
      "must": [
        {
          "term": {
            "kubernetes.namespace_name.keyword": "laa-review-criminal-legal-aid-production"
          }
        },
        { "range": { "@timestamp": { "gte": "now-7d" } } }
      ],
      "should": [
        { "match": { "log": "evidence_viewed" } },
        { "match": { "log": "evidence_downloaded" } }
      ],
      "minimum_should_match": 1
    }
  },
  "aggs": {
    "by_action": {
      "filters": {
        "filters": {
          "evidence_viewed": { "match": { "log": "evidence_viewed" } },
          "evidence_downloaded": { "match": { "log": "evidence_downloaded" } }
        }
      }
    }
  }
}
```

**Note:** Start with 7 days (`now-7d`) for faster results. Increase to `now-30d` as needed.

### Filter by Role

```json
{
  "query": {
    "bool": {
      "must": [
        {
          "term": {
            "kubernetes.namespace_name.keyword": "laa-review-criminal-legal-aid-production"
          }
        },
        { "match": { "log": "evidence_viewed" } },
        { "match": { "log": "supervisor" } },
        { "range": { "@timestamp": { "gte": "now-7d" } } }
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
        {
          "term": {
            "kubernetes.namespace_name.keyword": "laa-review-criminal-legal-aid-production"
          }
        },
        { "match": { "log": "evidence_downloaded" } },
        { "match": { "log": "not_assigned" } },
        { "range": { "@timestamp": { "gte": "now-7d" } } }
      ]
    }
  }
}
```

### Compare Assigned vs Not Assigned Downloads

```json
{
  "size": 0,
  "query": {
    "bool": {
      "must": [
        {
          "term": {
            "kubernetes.namespace_name.keyword": "laa-review-criminal-legal-aid-production"
          }
        },
        { "match": { "log": "evidence_downloaded" } },
        { "range": { "@timestamp": { "gte": "now-7d" } } }
      ]
    }
  },
  "aggs": {
    "by_assignment_status": {
      "filters": {
        "filters": {
          "assigned": {
            "match_phrase": { "log": "\"assigned\":\"assigned\"" }
          },
          "not_assigned": {
            "match_phrase": { "log": "\"assigned\":\"not_assigned\"" }
          }
        }
      }
    }
  }
}
```

### Assigned vs Not Assigned Downloads by Role

```json
{
  "size": 0,
  "query": {
    "bool": {
      "must": [
        {
          "term": {
            "kubernetes.namespace_name.keyword": "laa-review-criminal-legal-aid-production"
          }
        },
        { "match": { "log": "evidence_downloaded" } },
        { "range": { "@timestamp": { "gte": "now-7d" } } }
      ]
    }
  },
  "aggs": {
    "by_role": {
      "filters": {
        "filters": {
          "caseworker": {
            "match_phrase": { "log": "\"caseworker_role\":\"caseworker\"" }
          },
          "supervisor": {
            "match_phrase": { "log": "\"caseworker_role\":\"supervisor\"" }
          },
          "data_analyst": {
            "match_phrase": { "log": "\"caseworker_role\":\"data_analyst\"" }
          },
          "auditor": {
            "match_phrase": { "log": "\"caseworker_role\":\"auditor\"" }
          }
        }
      },
      "aggs": {
        "by_assignment_status": {
          "filters": {
            "filters": {
              "assigned": {
                "match_phrase": { "log": "\"assigned\":\"assigned\"" }
              },
              "not_assigned": {
                "match_phrase": { "log": "\"assigned\":\"not_assigned\"" }
              }
            }
          }
        }
      }
    }
  }
}
```

### Count Downloads by File Type

```json
{
  "size": 0,
  "query": {
    "bool": {
      "must": [
        {
          "term": {
            "kubernetes.namespace_name.keyword": "laa-review-criminal-legal-aid-production"
          }
        },
        { "match": { "log": "evidence_downloaded" } },
        { "range": { "@timestamp": { "gte": "now-7d" } } }
      ]
    }
  },
  "aggs": {
    "by_file_type": {
      "terms": {
        "script": {
          "source": "if (doc['log.keyword'].size() == 0) { return 'unknown'; } def m = /\"file_type\":\"([^\"]+)\"/.matcher(doc['log.keyword'].value); m.find() ? m.group(1) : 'unknown'"
        },
        "size": 10
      }
    }
  }
}
```

### Activity by Caseworker

```json
{
  "size": 0,
  "query": {
    "bool": {
      "must": [
        {
          "term": {
            "kubernetes.namespace_name.keyword": "laa-review-criminal-legal-aid-production"
          }
        },
        { "range": { "@timestamp": { "gte": "now-7d" } } }
      ],
      "should": [
        { "match": { "log": "evidence_viewed" } },
        { "match": { "log": "evidence_downloaded" } }
      ],
      "minimum_should_match": 1
    }
  },
  "aggs": {
    "by_caseworker": {
      "terms": {
        "script": {
          "source": "if (doc['log.keyword'].size() == 0) { return 'unknown'; } def m = /\"caseworker_id\":\"([^\"]+)\"/.matcher(doc['log.keyword'].value); m.find() ? m.group(1) : 'unknown'"
        },
        "size": 20
      }
    }
  }
}
```

### Time-based Analysis

```json
{
  "size": 0,
  "query": {
    "bool": {
      "must": [
        {
          "term": {
            "kubernetes.namespace_name.keyword": "laa-review-criminal-legal-aid-production"
          }
        },
        { "match": { "log": "evidence_viewed" } },
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
