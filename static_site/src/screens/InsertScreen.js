import React, { useState } from 'react';
import axios from 'axios';
// eslint-disable-next-line no-unused-vars
import { addDoc, collection } from 'firebase/firestore';
// eslint-disable-next-line no-unused-vars
import { db } from '../utils/firebase';

const InsertScreen = ({ setCurrentScreen, user }) => {
    const [date, setDate] = useState(new Date().toISOString().split('T')[0]);
    const [rows, setRows] = useState([{ exercise: '', weight: 0, reps: 0 }]);
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
        setRows([...rows, { exercise: '', weight: 0, reps: 0 }]);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        // Ensure the user is available before submitting
        if (!user || !user.email) {
            alert('User information is missing. Please log in again.');
            return;
        }

        const formattedData = {
            user: user.email, // Add user email to the payload
            date,
            exercises: rows.map((row) => ({
                name: row.exercise,
                weight: parseFloat(row.weight),
                reps: parseInt(row.reps, 10),
            })),
        };

        try {
            const response = await axios.post(
                'https://fitness.bernson.info/post',
                formattedData,
                {
                    headers: {
                        'Content-Type': 'application/json',
                        'x-api-key': process.env.REACT_APP_API_KEY,
                    },
                }
            );
            alert(`Records submitted successfully!\n${JSON.stringify(response.data, null, 2)}`);
            setRows([{ exercise: '', weight: 0, reps: 0 }]);
            setExpandedIndex(null);
            setCurrentScreen('home'); // Navigate back to the home screen
        } catch (error) {
            console.error('Error submitting records:', error);
            alert('Failed to submit records. Please try again.');
        }
    };

    return (
        <div className="insert-screen-container">
            <h2>Insert New Records</h2>
            <form onSubmit={handleSubmit} className="insert-form">
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
                            key={index}
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
