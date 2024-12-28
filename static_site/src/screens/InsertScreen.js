import React, { useState } from 'react';
import axios from 'axios';

// eslint-disable-next-line no-unused-vars
import { addDoc, collection } from 'firebase/firestore';
// eslint-disable-next-line no-unused-vars
import { db } from '../utils/firebase';

const InsertScreen = () => {
  const [date, setDate] = useState(new Date().toISOString().split('T')[0]); // Default to today’s date
  const [rows, setRows] = useState([{ exercise: '', weight: 0, reps: 0 }]); // Initial row

  // Handle changes in the date input
  const handleDateChange = (e) => {
    setDate(e.target.value); // Update the state with the selected date
  };

  // Handle changes in input fields
  const handleChange = (index, field, value) => {
    const updatedRows = [...rows];
    updatedRows[index][field] = value;
    setRows(updatedRows);
  };

  // Add a new empty row
  const handleAddRow = () => {
    setRows([...rows, { exercise: '', weight: 0, reps: 0 }]);
  };

  // Handle form submission
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
      // Send to API Gateway
      await axios.post('/post', formattedData, {
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': process.env.REACT_APP_API_KEY,
        },
      });
      console.log('Data sent to API Gateway successfully.');

      alert('Records submitted successfully to both Firebase and API Gateway!');
      setRows([{ exercise: '', weight: 0, reps: 0 }]); // Reset rows
    } catch (error) {
      console.error('Error submitting records:', error);
      alert('Failed to submit records. Check the console for details.');
    }
  };

  return (
    <div style={{ textAlign: 'center', marginTop: '50px' }}>
      <h2>Insert New Records</h2>
      <form onSubmit={handleSubmit}>
        {/* Date Picker */}
        <label>
          Date:
          <input
            type="date"
            value={date}
            onChange={handleDateChange}
            required
          />
        </label>

        {/* Exercise Table */}
        <table style={{ margin: '0 auto', borderCollapse: 'collapse', width: '80%' }}>
          <thead>
            <tr>
              <th>Exercise</th>
              <th>Weight (lbs)</th>
              <th>Reps</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row, index) => (
              <tr key={index}>
                <td>
                  <input
                    type="text"
                    value={row.exercise}
                    onChange={(e) => handleChange(index, 'exercise', e.target.value)}
                    placeholder="Exercise name"
                    required
                  />
                </td>
                <td>
                  <input
                    type="number"
                    value={row.weight}
                    onChange={(e) => handleChange(index, 'weight', e.target.value)}
                    placeholder="Weight"
                    required
                  />
                </td>
                <td>
                  <input
                    type="number"
                    value={row.reps}
                    onChange={(e) => handleChange(index, 'reps', e.target.value)}
                    placeholder="Reps"
                    required
                  />
                </td>
                <td>
                  {index === rows.length - 1 ? (
                    <button type="button" onClick={handleAddRow}>
                      Add
                    </button>
                  ) : null}
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {/* Submit Button */}
        <button type="submit" style={{ marginTop: '20px' }}>
          Submit
        </button>
      </form>
    </div>
  );
};

export default InsertScreen;
