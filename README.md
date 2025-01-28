# Poring.xyz

Welcome to the front-end to [My S3-based Image Uploader!](https://files.iqun.xyz)

## Installation instructions

```
git clone https://github.com/iqunlim/poring.xyz
cd poring-xyz && npm install
npm run dev to run in developer mode
npm run build to build the project in to a distributatble format
```

## Features

![Porings](https://files.iqun.xyz/GMZ6TTB4ET0B/poring.gif)

Porings. Everyone loves cute jelly monsters.

Simple, Lightweight front end

Handles images up to 20MB in size

## Project Goal

The goal of this project was to make an image uploader to an [AWS S3 bucket](https://aws.amazon.com/what-is/object-storage/) using an API located on AWS along with a netlify or vercel-hosted front-end.

I largely used the front end part of this project as a way to practice typescript, learn zod functionality for dealing with API return validation, and to practice css and tailwindcss

Libraries used:

Typescript

React

Zod

Tailwindcss

Terraform. You can find the terraform setup (with setups for a web server via AWS ECS instead of netlify) [here](https://github.com/iqunlim/poring.xyz.terraform)

## Challenges

Many of the challenges in this project involved AWS services and how to use them. They are very advanced and powerful, and each one comes with its own learning curve. Each small component required research and configuration.

In the backend, the API is a lambda function with specific permissions to serve an authorized upload URL. The way I generate the upload URL is very slow due to AWS Lambda functions' slow cold startup times. In the future I will likely not use this method for backend services unless the long start time is not a factor.

In the front end, zod took quite some time to get my head around. I ended up looking at tutorials specific to zod and reading the documentation extensively to get the most out of the incredible typescript-extending library.

## Future Plans - From most likely to least likely

CTRL+V functionality to paste images directly in from the clipboard.

Proper build and deployment steps, including making the API url an environment variable of some kind

A Dark mode (Deviling mode to those Ragnarok Online nerds out there)

Remake the API / make this project a nextjs application

Extend this beyond image uploads with a different storage solution backend and file chunking to allow larger stable uploads.

Additional functionality such as logins and file tracking.

## Acknowledgements

[Total Typescript](https://www.totaltypescript.com/) and their excellent Zod tutorial series

[Exampro](https://www.exampro.co/) for their AWS and Terraform lessons

### License

Both the terraform and the front end are licensed under GPL-3
