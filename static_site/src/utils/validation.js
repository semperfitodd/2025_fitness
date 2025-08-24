// Input validation utilities
export const validateExerciseData = (exerciseData) => {
    const errors = [];
    
    if (!exerciseData.exercise || exerciseData.exercise.trim() === '') {
        errors.push('Exercise name is required');
    }
    
    if (exerciseData.weight < 0) {
        errors.push('Weight cannot be negative');
    }
    
    if (exerciseData.reps < 0) {
        errors.push('Reps cannot be negative');
    }
    
    if (exerciseData.weight > 10000) {
        errors.push('Weight seems unrealistic (max 10,000 lbs)');
    }
    
    if (exerciseData.reps > 1000) {
        errors.push('Reps seem unrealistic (max 1,000)');
    }
    
    return errors;
};

export const validateDate = (date) => {
    if (!date) {
        return 'Date is required';
    }
    
    const selectedDate = new Date(date);
    const today = new Date();
    const oneYearAgo = new Date();
    oneYearAgo.setFullYear(today.getFullYear() - 1);
    
    if (selectedDate > today) {
        return 'Date cannot be in the future';
    }
    
    if (selectedDate < oneYearAgo) {
        return 'Date cannot be more than 1 year ago';
    }
    
    return null;
};
