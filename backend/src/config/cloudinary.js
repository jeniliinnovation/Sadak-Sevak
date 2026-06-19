const path = require('path');
const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

const cloudinaryConfig = {};

if (process.env.CLOUDINARY_URL) {
  cloudinaryConfig.cloudinary_url = process.env.CLOUDINARY_URL;
} else {
  cloudinaryConfig.cloud_name = process.env.CLOUDINARY_NAME;
  cloudinaryConfig.api_key = process.env.CLOUDINARY_API_KEY;
  cloudinaryConfig.api_secret = process.env.CLOUDINARY_API_SECRET;
}

if (!cloudinaryConfig.cloudinary_url && (!cloudinaryConfig.cloud_name || !cloudinaryConfig.api_key || !cloudinaryConfig.api_secret)) {
  console.warn('Cloudinary is not fully configured. Set CLOUDINARY_URL or CLOUDINARY_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET.');
}

cloudinary.config({
  ...cloudinaryConfig,
  secure: true,
});

const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'sadak-sevak',
    allowed_formats: ['jpg', 'png', 'jpeg', 'mp4'],
    resource_type: 'auto'
  }
});

module.exports = {
  cloudinary,
  storage
};
