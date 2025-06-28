-- Function that takes a name and returns a personalized greeting
CREATE OR REPLACE FUNCTION greet_user(user_name TEXT)
RETURNS TEXT AS $$
BEGIN
RETURN 'Hello, ' || user_name || '! Welcome to PostgreSQL!';
END;
$$ LANGUAGE plpgsql;
-- How to call it:
SELECT greet_user('Alice');
SELECT greet_user('Bob');