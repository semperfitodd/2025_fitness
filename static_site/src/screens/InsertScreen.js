import React, {useState} from 'react';
import axios from 'axios';
// eslint-disable-next-line no-unused-vars
import { addDoc, collection } from 'firebase/firestore';
// eslint-disable-next-line no-unused-vars
import { db } from '../utils/firebase';

const InsertScreen = ({setCurrentScreen}) => {
    const [date, setDate] = useState(new Date().toISOString().split('T')[0]);
    const [rows, setRows] = useState([{exercise: '', weight: 0, reps: 0}]);
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
        setRows([...rows, {exercise: '', weight: 0, reps: 0}]);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        const formattedData = {
            date,
            exercises: rows.map((row) => ({
                name: row.exercise,
                weight: parseFloat(row.weight),
                reps: parseInt(row.reps, 10),
            })),
        };

        try {
            await axios.post('/post', formattedData, {
                headers: {
                    'Content-Type': 'application/json',
                    'x-api-key': process.env.REACT_APP_API_KEY,
                },
            });
            alert('Records submitted successfully!');
            setRows([{exercise: '', weight: 0, reps: 0}]);
            setExpandedIndex(null);
            setCurrentScreen('home'); // Navigate back to the home screen
        } catch (error) {
            alert('Failed to submit records.');
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
