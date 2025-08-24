import { useMemo } from 'react';
import { FITNESS_CONSTANTS } from '../utils/constants';

export const useDateCalculations = () => {
    const calculations = useMemo(() => {
        const currentDate = new Date();
        const startOfYear = new Date(currentDate.getFullYear(), 0, 1);
        const daysIntoYear = Math.floor((currentDate - startOfYear) / (1000 * 60 * 60 * 24)) + 1;
        const daysIntoYearPercentage = Math.round((daysIntoYear / FITNESS_CONSTANTS.DAYS_IN_YEAR) * 100 * 100) / 100;

        return {
            currentDate,
            startOfYear,
            daysIntoYear,
            daysIntoYearPercentage
        };
    }, []);

    return calculations;
};
