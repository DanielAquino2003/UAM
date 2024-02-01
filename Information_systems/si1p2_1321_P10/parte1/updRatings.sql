CREATE OR REPLACE FUNCTION updateRatings()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Se ha añadido una nueva valoración
        UPDATE imdb_movies
        SET
            ratingcount = ratingcount + 1,
            ratingmean = (ratingmean * COALESCE(ratingcount, 0) + NEW.rating) / COALESCE(ratingcount + 1, 1);
    ELSIF TG_OP = 'UPDATE' THEN
        -- Se ha actualizado una valoración
        UPDATE imdb_movies
        SET
            ratingmean = (ratingmean * COALESCE(ratingcount, 0) - OLD.rating + NEW.rating) / COALESCE(ratingcount, 1);
    ELSIF TG_OP = 'DELETE' THEN
        -- Se ha eliminado una valoración
        UPDATE imdb_movies
        SET
            ratingcount = ratingcount - 1,
            ratingmean = CASE
                WHEN ratingcount > 1 THEN (ratingmean * COALESCE(ratingcount, 0) - OLD.rating) / COALESCE(ratingcount - 1, 1)
                ELSE NULL
            END;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER updRatings
AFTER INSERT OR UPDATE OR DELETE ON ratings
FOR EACH ROW
EXECUTE FUNCTION updateRatings();