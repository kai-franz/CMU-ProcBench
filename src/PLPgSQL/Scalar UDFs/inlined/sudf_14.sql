
            SELECT NOT isListDistinct(', ' || STRING_AGG(s_manager, ', '), ',')
              FROM store
             WHERE s_number_employees > 250;
          