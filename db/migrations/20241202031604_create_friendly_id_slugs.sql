CREATE TABLE friendly_id_slugs (
  id BIGSERIAL PRIMARY KEY,
  slug VARCHAR NOT NULL,
  sluggable_id BIGINT NOT NULL,
  sluggable_type VARCHAR(50) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX index_friendly_id_slugs_on_sluggable ON friendly_id_slugs (sluggable_type, sluggable_id);