import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const destinations = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/destinations' }),
  schema: z.object({
    title: z.string(),
    country: z.string(),
    region: z.enum(['europe', 'americas', 'asia', 'oceania', 'africa']),
    heroImage: z.string().url(),
    heroImageAlt: z.string(),
    images: z.array(z.object({
      url: z.string().url(),
      alt: z.string(),
    })),
    summary: z.string(),
    bestMonths: z.array(z.number().min(1).max(12)),
    tripLength: z.string(),
    hotelCostPerNight: z.number(),
    flightCostReturn: z.number(),
    nutAllergyRating: z.number().min(1).max(5),
    vegetarianRating: z.number().min(1).max(5),
    allergenNotes: z.string(),
    vegetarianNotes: z.string(),
  }),
});

export const collections = { destinations };
