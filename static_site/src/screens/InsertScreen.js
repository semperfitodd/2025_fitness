import React, { useState } from 'react';
import axios from 'axios';
import { API_ENDPOINTS, FITNESS_CONSTANTS } from '../utils/constants';
import { validateExerciseData, validateDate } from '../utils/validation';
import { logError, logUserAction } from '../utils/errorTracking';

const InsertScreen = ({ setCurrentScreen, user }) => {
    const [date, setDate] = useState(new Date().toISOString().split('T')[0]);
    const [rows, setRows] = useState([{ ...FITNESS_CONSTANTS.DEFAULT_EXERCISE_ROW, id: Date.now() }]);
    const [expandedIndex, setExpandedIndex] = useState(null);

    const handleDateChange = (e) => {
        setDate(e.target.value);
    };

    const handleChange = (index, field, value) => {
        const updatedRows = [...rows];
        updatedRows[index][field] = value;
        setRows(updatedRows);
    };

    const handleAddRow = () => {
        setRows([...rows, { ...FITNESS_CONSTANTS.DEFAULT_EXERCISE_ROW, id: Date.now() }]);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        // Ensure the user is available before submitting
        if (!user || !user.email) {
            logError(new Error('User information missing'), { screen: 'InsertScreen' });
            alert('User information is missing. Please log in again.');
            return;
        }

        // Validate date
        const dateError = validateDate(date);
        if (dateError) {
            alert(`Date Error: ${dateError}`);
            return;
        }

        // Validate all exercise data
        const validationErrors = [];
        rows.forEach((row, index) => {
            const errors = validateExerciseData(row);
            if (errors.length > 0) {
                validationErrors.push(`Row ${index + 1}: ${errors.join(', ')}`);
            }
        });

        if (validationErrors.length > 0) {
            alert(`Validation Errors:\n${validationErrors.join('\n')}`);
            return;
        }

        const formattedData = {
            user: user.email,
            date,
            exercises: rows.map((row) => ({
                name: row.exercise,
                weight: parseFloat(row.weight),
                reps: parseInt(row.reps, 10),
            })),
        };

        try {
            logUserAction('submit_exercises', { 
                exerciseCount: rows.length, 
                date: date 
            });

            await axios.post(
                API_ENDPOINTS.POST,
                formattedData,
                {
                    headers: {
                        'Content-Type': 'application/json',
                        'x-api-key': process.env.REACT_APP_API_KEY,
                    },
                }
            );

            // Calculate the total lbs lifted for the day
            const totalLbsLifted = formattedData.exercises.reduce(
                (total, exercise) => total + (exercise.weight * exercise.reps),
                0
            );

            alert(`Records submitted successfully! Total lifted today: ${totalLbsLifted.toLocaleString()} lbs.`);

            setRows([{ ...FITNESS_CONSTANTS.DEFAULT_EXERCISE_ROW, id: Date.now() }]);
            setExpandedIndex(null);
            setCurrentScreen('home');
        } catch (error) {
            logError(error, { 
                screen: 'InsertScreen', 
                action: 'submit_exercises',
                data: formattedData 
            });
            console.error('Error submitting records:', error);
            alert('Failed to submit records. Please try again.');
        }
    };

    return (
        <div className="insert-screen-container fade-in">
            <h2>Insert New Records</h2>
            <form onSubmit={handleSubmit} className="insert-form scale-in">
                <label className="date-label">
                    Date:
                    <input
                        type="date"
                        value={date}
                        onChange={handleDateChange}
                        required
                    />
                </label>
                <div className="exercise-container">
                    {rows.map((row, index) => (
                        <div
                            key={row.id || index}
                            className={`exercise-row ${
                                expandedIndex === index ? 'expanded' : ''
                            }`}
                            onClick={() =>
                                setExpandedIndex(expandedIndex === index ? null : index)
                            }
                        >
                            {expandedIndex === index ? (
                                <div
                                    className="expanded-inputs"
                                    onClick={(e) => e.stopPropagation()}
                                >
                                    <input
                                        type="text"
                                        value={row.exercise}
                                        onChange={(e) =>
                                            handleChange(index, 'exercise', e.target.value)
                                        }
                                        placeholder="Exercise name"
                                        required
                                    />
                                    <input
                                        type="number"
                                        value={row.weight}
                                        onChange={(e) =>
                                            handleChange(index, 'weight', e.target.value)
                                        }
                                        placeholder="Weight (lbs)"
                                        required
                                    />
                                    <input
                                        type="number"
                                        value={row.reps}
                                        onChange={(e) =>
                                            handleChange(index, 'reps', e.target.value)
                                        }
                                        placeholder="Reps"
                                        required
                                    />
                                </div>
                            ) : (
                                <p>
                                    {row.exercise || 'New Exercise'} - {row.weight} lbs x {row.reps}{' '}
                                    reps
                                </p>
                            )}
                        </div>
                    ))}
                    <button type="button" className="add-button" onClick={handleAddRow}>
                        Add Exercise
                    </button>
                </div>
                <button type="submit" className="submit-button">
                    Submit
                </button>
            </form>
        </div>
    );
};

export default InsertScreen;
