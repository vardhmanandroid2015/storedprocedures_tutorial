-- Function to calculate the area of a circle
CREATE OR REPLACE FUNCTION calculate_circle_area(radius NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
RETURN 3.14159 * radius * radius;
END;
$$ LANGUAGE plpgsql;

-- How to call it:
SELECT calculate_circle_area(5);
SELECT calculate_circle_area(10.5);