import React, { useState } from 'react';
import axios from 'axios';

// eslint-disable-next-line no-unused-vars
import { addDoc, collection } from 'firebase/firestore';
// eslint-disable-next-line no-unused-vars
import { db } from '../utils/firebase';

const InsertScreen = () => {
  const [date, setDate] = useState(new Date().toISOString().split('T')[0]); // Default to today’s date
  const [rows, setRows] = useState([{ exercise: '', weight: 0, reps: 0 }]); // Initial row

  const handleDateChange = (e) => {
    setDate(e.target.value); // Update the state with the selected date
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
      setRows([{ exercise: '', weight: 0, reps: 0 }]);
    } catch (error) {
      console.error('Error submitting records:', error);
      alert('Failed to submit records.');
    }
  };

  return (
    <div style={{ textAlign: 'center', marginTop: '20px' }}>
      <h2>Insert New Records</h2>
      <form onSubmit={handleSubmit} style={{ width: '70%', margin: '0 auto' }}>
        <label style={{ display: 'block', marginBottom: '10px' }}>
          Date:
          <input
            type="date"
            value={date}
            onChange={handleDateChange}
            style={{ marginLeft: '10px' }}
            required
          />
        </label>
        <div style={{ marginBottom: '20px' }}>
          {rows.map((row, index) => (
            <div
              key={index}
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                gap: '10px',
                marginBottom: '10px',
              }}
            >
              <input
                type="text"
                value={row.exercise}
                onChange={(e) => handleChange(index, 'exercise', e.target.value)}
                placeholder="Exercise name"
                required
                style={{
                  flex: 2,
                  padding: '10px',
                  fontSize: '16px',
                  borderRadius: '5px',
                  border: '1px solid #ccc',
                }}
              />
              <input
                type="number"
                value={row.weight}
                onChange={(e) => handleChange(index, 'weight', e.target.value)}
                placeholder="Weight (lbs)"
                required
                style={{
                  flex: 1,
                  padding: '10px',
                  fontSize: '16px',
                  borderRadius: '5px',
                  border: '1px solid #ccc',
                }}
              />
              <input
                type="number"
                value={row.reps}
                onChange={(e) => handleChange(index, 'reps', e.target.value)}
                placeholder="Reps"
                required
                style={{
                  flex: 1,
                  padding: '10px',
                  fontSize: '16px',
                  borderRadius: '5px',
                  border: '1px solid #ccc',
                }}
              />
              {index === rows.length - 1 && (
                <button
                  type="button"
                  onClick={handleAddRow}
                  style={{
                    flex: 1,
                    padding: '10px',
                    fontSize: '16px',
                    backgroundColor: '#0078d4',
                    color: 'white',
                    border: 'none',
                    borderRadius: '5px',
                  }}
                >
                  Add
                </button>
              )}
            </div>
          ))}
        </div>
        <button
          type="submit"
          style={{
            backgroundColor: '#0078d4',
            color: 'white',
            border: 'none',
            padding: '10px 20px',
            borderRadius: '5px',
            fontSize: '16px',
            marginTop: '10px',
          }}
        >
          Submit
        </button>
      </form>
    </div>
  );
};

export default InsertScreen;
