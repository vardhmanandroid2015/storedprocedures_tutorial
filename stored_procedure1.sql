-- Create a simple function that returns a greeting
CREATE OR REPLACE FUNCTION say_hello()
RETURNS TEXT AS $$
BEGIN
RETURN 'Hello, World!';
END;
$$ LANGUAGE plpgsql;

-- How to call it:
SELECT say_hello();