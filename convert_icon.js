const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const svgPath = path.join(__dirname, 'icon_designs', 'design_e_star_chart.svg');
const svgBuffer = fs.readFileSync(svgPath);

const sizes = [
  { name: 'Icon-192.png', size: 192 },
  { name: 'Icon-512.png', size: 512 },
  { name: 'Icon-maskable-192.png', size: 192 },
  { name: 'Icon-maskable-512.png', size: 512 },
  { name: 'favicon.png', size: 16 },
];

async function convert() {
  for (const { name, size } of sizes) {
    const outputPath = path.join(__dirname, 'web', 'icons', name);
    if (name === 'favicon.png') {
      await sharp(svgBuffer)
        .resize(size, size)
        .png()
        .toFile(path.join(__dirname, 'web', name));
      console.log(`Created web/${name}`);
    } else {
      await sharp(svgBuffer)
        .resize(size, size)
        .png()
        .toFile(outputPath);
      console.log(`Created web/icons/${name}`);
    }
  }
  
  // Also create for build/web
  for (const { name, size } of sizes) {
    if (name === 'favicon.png') {
      await sharp(svgBuffer)
        .resize(size, size)
        .png()
        .toFile(path.join(__dirname, 'build', 'web', name));
    } else {
      await sharp(svgBuffer)
        .resize(size, size)
        .png()
        .toFile(path.join(__dirname, 'build', 'web', 'icons', name));
    }
  }
  console.log('All icons generated!');
}

convert().catch(console.error);
