<script setup lang="ts">
type WhoBloodStats = {
  donations: string;
  ratePer1000: string;
  year: number;
  source: string;
  error?: string;
};

const athensStats = {
  donors: "10,000+",
  livesSaved: "25,000+",
  donationCenters: "50+",
  support: "24/7",
};

const { data: whoStats, pending } = await useFetch<WhoBloodStats>(
  "/api/who-blood-greece",
);

const user = useSupabaseUser();
</script>

<template>
  <div>
    <!-- Hero Section -->
    <section
      class="relative h-[400px] flex items-center justify-center overflow-hidden"
    >
      <div
        class="absolute inset-0 bg-gradient-to-r from-gray-900/95 to-gray-900/80 z-10"
      ></div>
      <div
        class="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1615461066159-fea0960485d5?w=1920')] bg-cover bg-center"
      ></div>

      <div
        class="relative z-20 max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 text-center text-white"
      >
        <h1 class="text-3xl md:text-4xl font-bold mb-3 leading-tight">
          Donate Blood & Save a Life
        </h1>

        <p
          class="text-base md:text-lg mb-6 text-gray-200 max-w-2xl mx-auto"
        >
          Your blood donation can give someone a second chance at life. Join thousands of donors making a difference.
        </p>

        <div v-if="!user" class="flex gap-3 justify-center flex-wrap">
          <NuxtLink
            to="/register"
            class="bg-red-600 text-white px-6 py-2.5 rounded-md font-semibold text-sm hover:bg-red-700 transition inline-block"
          >
            Become a Donor
          </NuxtLink>

          <NuxtLink
            to="/login"
            class="bg-white text-gray-900 px-6 py-2.5 rounded-md font-semibold text-sm hover:bg-gray-100 transition inline-block"
          >
            Login to Portal
          </NuxtLink>
        </div>
      </div>
    </section>

    <!-- Stats Section -->
    <section class="py-8 bg-gray-50 border-y border-gray-200">
      <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        <h2 class="text-lg font-bold text-center text-gray-900 mb-4">
          Blood Donation Impact in Greece
        </h2>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-3 text-center">
          <!-- WHO Total Donations -->
          <div class="p-3 bg-white rounded border border-gray-200">
            <div class="text-xl font-bold text-primary-600 mb-0.5">
              <span v-if="pending">
                <div class="inline-block animate-spin rounded-full h-5 w-5 border-b-2 border-primary-600"></div>
              </span>
              <span v-else>{{ whoStats?.donations ?? "N/A" }}</span>
            </div>
            <div class="text-xs text-gray-600 font-medium">Annual Donations</div>
            <div class="text-[10px] text-gray-400 mt-0.5">
              {{ whoStats?.year ? `Year: ${whoStats.year}` : "-" }}
            </div>
          </div>

          <!-- WHO Rate per 1000 -->
          <div class="p-3 bg-white rounded border border-gray-200">
            <div class="text-xl font-bold text-primary-600 mb-0.5">
              <span v-if="pending">
                <div class="inline-block animate-spin rounded-full h-5 w-5 border-b-2 border-primary-600"></div>
              </span>
              <span v-else>{{ whoStats?.ratePer1000 ?? "N/A" }}</span>
            </div>
            <div class="text-xs text-gray-600 font-medium">Donation Rate</div>
            <div class="text-[10px] text-gray-400 mt-0.5">
              Per 1,000 population
            </div>
          </div>

          <!-- Lives Saved -->
          <div class="p-3 bg-white rounded border border-gray-200">
            <div class="text-xl font-bold text-primary-600 mb-0.5">
              {{ athensStats.livesSaved }}
            </div>
            <div class="text-xs text-gray-600 font-medium">Lives Saved</div>
            <div class="text-[10px] text-gray-400 mt-0.5">
              Up to 3 lives per donation
            </div>
          </div>

          <!-- 24/7 Support -->
          <div class="p-3 bg-white rounded border border-gray-200">
            <div class="text-xl font-bold text-primary-600 mb-0.5">
              {{ athensStats.support }}
            </div>
            <div class="text-xs text-gray-600 font-medium">Support Available</div>
            <div class="text-[10px] text-gray-400 mt-0.5">
              Always here to help
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- About Section -->
    <section class="py-12 bg-white">
      <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">
          <div>
            <h2 class="text-2xl font-bold text-gray-900 mb-4">
              About Blood Donors
            </h2>

            <p class="text-sm text-gray-700 mb-3 leading-relaxed">
              Our Blood Donation System connects voluntary blood donors with
              those in urgent need. We maintain a comprehensive database of
              donors and facilitate the entire donation process from
              registration to collection.
            </p>

            <p class="text-sm text-gray-700 mb-4 leading-relaxed">
              Every two seconds, someone needs blood. Your donation can make the
              difference between life and death for patients undergoing surgery,
              cancer treatment, or facing medical emergencies.
            </p>

            <ul class="space-y-2">
              <li class="flex items-start gap-2">
                <svg
                  class="w-4 h-4 text-primary-600 flex-shrink-0 mt-0.5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M5 13l4 4L19 7"
                  />
                </svg>
                <span class="text-sm text-gray-700"
                  >Safe and sterile donation process</span
                >
              </li>

              <li class="flex items-start gap-2">
                <svg
                  class="w-4 h-4 text-primary-600 flex-shrink-0 mt-0.5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M5 13l4 4L19 7"
                  />
                </svg>
                <span class="text-sm text-gray-700">Professional medical staff</span>
              </li>

              <li class="flex items-start gap-2">
                <svg
                  class="w-4 h-4 text-primary-600 flex-shrink-0 mt-0.5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M5 13l4 4L19 7"
                  />
                </svg>
                <span class="text-sm text-gray-700"
                  >Quick and easy online registration</span
                >
              </li>

              <li class="flex items-start gap-2">
                <svg
                  class="w-4 h-4 text-primary-600 flex-shrink-0 mt-0.5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M5 13l4 4L19 7"
                  />
                </svg>
                <span class="text-sm text-gray-700">Track your donation history</span>
              </li>
            </ul>
          </div>

          <div class="relative">
            <div class="aspect-square rounded-lg overflow-hidden shadow-lg">
              <div
                class="w-full h-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-32 w-32 text-white opacity-20"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                >
                  <path
                    d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"
                  />
                </svg>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section v-if="!user" class="py-10 bg-primary-600 text-white">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h2 class="text-2xl font-bold mb-3">Ready to Save Lives?</h2>
        <p class="text-sm mb-5 text-primary-100">
          Join our community of heroes. Register today and make your first donation.
        </p>
        <NuxtLink
          to="/register"
          class="bg-white text-primary-600 px-6 py-2.5 rounded-md font-semibold text-sm hover:bg-gray-100 transition inline-block"
        >
          Register Now
        </NuxtLink>
      </div>
    </section>
  </div>
</template>
