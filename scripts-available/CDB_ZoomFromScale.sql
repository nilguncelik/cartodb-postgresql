-- Maximum supported zoom level
CREATE OR REPLACE FUNCTION _CDB_MaxSupportedZoom()
RETURNS int
LANGUAGE SQL
IMMUTABLE
AS $$
  -- The maximum zoom level has to be limited for various reasons,
  -- e.g. zoom levels greater than 31 would require tile coordinates
  -- that would not fit in an INTEGER (which is signed, 32 bits long).
  -- We'll choose 20 as a limit which is safe also when the JavaScript shift
  -- operator (<<) is used for computing powers of two.
  SELECT 29;
$$;

CREATE OR REPLACE FUNCTION cartodb.CDB_ZoomFromScale(scaleDenominator numeric)
RETURNS int
LANGUAGE SQL
IMMUTABLE
AS $$
SELECT
  CASE
    -- Don't bother if the scale is larger than ~zoom level 0
    WHEN scaleDenominator > 600000000 OR scaleDenominator = 0 THEN NULL
    WHEN scaleDenominator = 0 THEN _CDB_MaxSupportedZoom()
    ELSE CAST (LEAST(ROUND(LOG(2, 559082264.028/scaleDenominator)), _CDB_MaxSupportedZoom()) AS INTEGER)
  END;
$$;
