-- Function to safely divide two numbers
CREATE OR REPLACE FUNCTION safe_divide(numerator NUMERIC, denominator NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
IF denominator = 0 THEN
RAISE EXCEPTION 'Division by zero is not allowed';
END IF;
RETURN numerator / denominator;
EXCEPTION
WHEN OTHERS THEN
RAISE NOTICE 'An error occurred: %', SQLERRM;
RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- How to call it:
SELECT safe_divide(10, 2); -- Returns 5
SELECT safe_divide(10, 0); -- Raises exception