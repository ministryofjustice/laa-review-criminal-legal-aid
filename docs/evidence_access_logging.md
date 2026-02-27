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

### View vs Download Ratio by File Type

Compare viewing and downloading behavior across different file types to understand how users interact with different content formats.

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
    "by_file_type": {
      "terms": {
        "script": {
          "source": "def log = params._source.log; if (log == null) return 'unknown'; def matcher = /\"file_type\":\"([^\"]+)\"/.matcher(log); return matcher.find() ? matcher.group(1) : 'unknown';",
          "lang": "painless"
        },
        "size": 10
      },
      "aggs": {
        "by_action": {
          "filters": {
            "filters": {
              "evidence_viewed": { "match": { "log": "evidence_viewed" } },
              "evidence_downloaded": {
                "match": { "log": "evidence_downloaded" }
              }
            }
          }
        }
      }
    }
  }
}
```

**Returns:** For each file type, shows the count of views vs downloads. Calculate ratio as `views / downloads`. Example response structure:

```json
{
  "aggregations": {
    "by_file_type": {
      "buckets": [
        {
          "key": "application/pdf",
          "doc_count": 142,
          "by_action": {
            "buckets": {
              "evidence_viewed": { "doc_count": 89 },
              "evidence_downloaded": { "doc_count": 53 }
            }
          }
        },
        {
          "key": "image/jpeg",
          "doc_count": 78,
          "by_action": {
            "buckets": {
              "evidence_viewed": { "doc_count": 62 },
              "evidence_downloaded": { "doc_count": 16 }
            }
          }
        }
      ]
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

### Daily Trends: Views vs Downloads Over Time

Track daily counts for both evidence viewing and downloading events to visualize trends and compare behavior patterns over time.

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
    "daily_trends": {
      "date_histogram": {
        "field": "@timestamp",
        "calendar_interval": "day"
      },
      "aggs": {
        "by_action": {
          "filters": {
            "filters": {
              "evidence_viewed": { "match": { "log": "evidence_viewed" } },
              "evidence_downloaded": {
                "match": { "log": "evidence_downloaded" }
              }
            }
          }
        }
      }
    }
  }
}
```

**Returns:** Daily buckets with separate counts for views and downloads. Example response structure:

```json
{
  "aggregations": {
    "daily_trends": {
      "buckets": [
        {
          "key_as_string": "2024-01-15T00:00:00.000Z",
          "key": 1705276800000,
          "doc_count": 45,
          "by_action": {
            "buckets": {
              "evidence_viewed": { "doc_count": 28 },
              "evidence_downloaded": { "doc_count": 17 }
            }
          }
        }
      ]
    }
  }
}
```
