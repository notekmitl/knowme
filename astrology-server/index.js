const express = require("express");
const cors = require("cors");
const swisseph = require("swisseph");

const app = express();

const zodiacSigns = [
  "Aries",
  "Taurus",
  "Gemini",
  "Cancer",
  "Leo",
  "Virgo",
  "Libra",
  "Scorpio",
  "Sagittarius",
  "Capricorn",
  "Aquarius",
  "Pisces"
];

function degreeToZodiac(deg) {
  const signIndex = Math.floor(deg / 30);
  const sign = zodiacSigns[signIndex];
  const degreeInSign = deg % 30;

  return {
    sign,
    degree: degreeInSign.toFixed(2)
  };
}
app.use(cors());

swisseph.swe_set_ephe_path(__dirname + "/ephe");

app.get("/planet", (req, res) => {
  const { year, month, day, hour } = req.query;

  const jd = swisseph.swe_julday(
    Number(year),
    Number(month),
    Number(day),
    Number(hour),
    swisseph.SE_GREG_CAL
  );

  const result = swisseph.swe_calc_ut(
    jd,
    swisseph.SE_SUN,
    swisseph.SEFLG_SWIEPH
  );

  const zodiacPlanets = {};

for (const key in planets) {
  zodiacPlanets[key] = degreeToZodiac(planets[key]);
}

res.json({
  julian,
  planets,
  zodiac: zodiacPlanets
});
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});