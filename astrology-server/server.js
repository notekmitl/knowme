const express = require("express");
const cors = require("cors");
const swisseph = require("swisseph");

const app = express();
app.use(cors());

swisseph.swe_set_ephe_path(__dirname + "/ephe");

const zodiacSigns = [
  "Aries","Taurus","Gemini","Cancer",
  "Leo","Virgo","Libra","Scorpio",
  "Sagittarius","Capricorn","Aquarius","Pisces"
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

function getElement(sign) {
  const fire = ["Aries", "Leo", "Sagittarius"];
  const earth = ["Taurus", "Virgo", "Capricorn"];
  const air = ["Gemini", "Libra", "Aquarius"];
  const water = ["Cancer", "Scorpio", "Pisces"];

  if (fire.includes(sign)) return "Fire";
  if (earth.includes(sign)) return "Earth";
  if (air.includes(sign)) return "Air";
  if (water.includes(sign)) return "Water";

  return "";
}

const chineseAnimals = [
  "Rat","Ox","Tiger","Rabbit",
  "Dragon","Snake","Horse","Goat",
  "Monkey","Rooster","Dog","Pig"
];

function getChineseZodiac(year) {
  const index = (year - 4) % 12;
  return chineseAnimals[index];
}

app.get("/chart", (req, res) => {

  const { year, month, day, hour, lat, lng } = req.query;

  const jd = swisseph.swe_julday(
    Number(year),
    Number(month),
    Number(day),
    Number(hour),
    swisseph.SE_GREG_CAL
  );

  function calcPlanet(planet) {
    const r = swisseph.swe_calc_ut(jd, planet, swisseph.SEFLG_SWIEPH);
    return r.longitude;
  }

  const planets = {
    sun: calcPlanet(swisseph.SE_SUN),
    moon: calcPlanet(swisseph.SE_MOON),
    mercury: calcPlanet(swisseph.SE_MERCURY),
    venus: calcPlanet(swisseph.SE_VENUS),
    mars: calcPlanet(swisseph.SE_MARS),
    jupiter: calcPlanet(swisseph.SE_JUPITER),
    saturn: calcPlanet(swisseph.SE_SATURN),
    uranus: calcPlanet(swisseph.SE_URANUS),
    neptune: calcPlanet(swisseph.SE_NEPTUNE),
    pluto: calcPlanet(swisseph.SE_PLUTO),
  };

  /// ===== Ascendant =====

  const houses = swisseph.swe_houses(
    jd,
    Number(lat),
    Number(lng),
    "P"
  );

  const ascendantDeg = houses.ascendant;

  /// ===== Zodiac convert =====

  const zodiacPlanets = {};
  for (const key in planets) {
    zodiacPlanets[key] = degreeToZodiac(planets[key]);
  }

  const ascendant = degreeToZodiac(ascendantDeg);

  /// ⭐ Sun sign
  const sunSign = zodiacPlanets.sun.sign;

  /// ⭐ Element
  const element = getElement(sunSign);

  /// ⭐ Chinese zodiac
  const chineseZodiac = getChineseZodiac(Number(year));

  res.json({
    julian: jd,
    planets,
    zodiac: zodiacPlanets,
    ascendant,
    element,
    chineseZodiac
  });

});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});