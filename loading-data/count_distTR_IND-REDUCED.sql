#counts the reduced individual population
SELECT [1-Synth_popul_REDUCED].distTR, Count([1-Synth_popul_REDUCED].distTR) AS CountOfdistTR
FROM [1-Synth_popul_REDUCED]
GROUP BY [1-Synth_popul_REDUCED].distTR
ORDER BY Count([1-Synth_popul_REDUCED].distTR) DESC;
