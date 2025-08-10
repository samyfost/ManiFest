using ManiFest.Services.Helpers;
using Microsoft.EntityFrameworkCore;
using System;

namespace ManiFest.Services.Database
{
    public static class DataSeeder
    {
        private const string DefaultPhoneNumber = "+387 00 000 000";
        
        private const string TestMailReceiver = "calltaxi.receiver@gmail.com";

        public static void SeedData(this ModelBuilder modelBuilder)
        {
            // Use a fixed date for all timestamps
            var fixedDate = new DateTime(2025, 5, 5, 0, 0, 0, DateTimeKind.Utc);

            // Seed Roles
            modelBuilder.Entity<Role>().HasData(
                new Role 
                { 
                    Id = 1, 
                    Name = "Administrator", 
                    Description = "System administrator with full access", 
                    CreatedAt = fixedDate, 
                    IsActive = true 
                },
                new Role 
                { 
                    Id = 2, 
                    Name = "User", 
                    Description = "Regular user role", 
                    CreatedAt = fixedDate, 
                    IsActive = true 
                }
            );

            // Seed Users
            modelBuilder.Entity<User>().HasData(
                new User 
                {
                    Id = 1,
                    FirstName = "Denis",
                    LastName = "Mušić",
                    Email = "example1@gmail.com",
                    Username = "admin",
                    PasswordHash = "3KbrBi5n9zdQnceWWOK5zaeAwfEjsluyhRQUbNkcgLQ=",
                    PasswordSalt = "6raKZCuEsvnBBxPKHGpRtA==",
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 1, // Sarajevo
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "denis.png")
                },
                new User 
                { 
                    Id = 2, 
                    FirstName = "Amel", 
                    LastName = "Musić",
                    Email = TestMailReceiver,
                    Username = "user", 
                    PasswordHash = "kDPVcZaikiII7vXJbMEw6B0xZ245I29ocaxBjLaoAC0=", 
                    PasswordSalt = "O5R9WmM6IPCCMci/BCG/eg==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 5, // Mostar
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "amel.png")
                },
                new User 
                { 
                    Id = 3, 
                    FirstName = "Adil", 
                    LastName = "Joldić",
                    Email = "example2@gmail.com",
                    Username = "admin2", 
                    PasswordHash = "BiWDuil9svAKOYzii5wopQW3YqjVfQrzGE2iwH/ylY4=", 
                    PasswordSalt = "pfNS+OLBaQeGqBIzXXcWuA==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 3, // Tuzla
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "adil.png")
                },
                new User 
                { 
                    Id = 4, 
                    FirstName = "Lejla", 
                    LastName = "Bašić", 
                    Email = "lejla.basic@edu.fit.ba", 
                    Username = "user2", 
                    PasswordHash = "KUF0Jsocq9AqdwR9JnT2OrAqm5gDj7ecQvNwh6fW/Bs=", 
                    PasswordSalt = "c3ZKo0va3tYfnYuNKkHDbQ==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 2, // Female
                    CityId = 1, // Sarajevo
                    //Picture = ImageConversion.ConvertImageToByteArray("Assets", "test.png")
                }
            );

            // Seed UserRoles
            modelBuilder.Entity<UserRole>().HasData(
                new UserRole { Id = 1, UserId = 1, RoleId = 1, DateAssigned = fixedDate }, 
                new UserRole { Id = 2, UserId = 2, RoleId = 2, DateAssigned = fixedDate }, 
                new UserRole { Id = 3, UserId = 3, RoleId = 1, DateAssigned = fixedDate }, 
                new UserRole { Id = 4, UserId = 4, RoleId = 2, DateAssigned = fixedDate }  
            );

            // Seed Genders
            modelBuilder.Entity<Gender>().HasData(
                new Gender { Id = 1, Name = "Male" },
                new Gender { Id = 2, Name = "Female" }
            );


 
            // Seed Categories
            modelBuilder.Entity<Category>().HasData(
                new Category { Id = 1, Name = "Music", Description = "Music festivals and events", CreatedAt = fixedDate, IsActive = true },
                new Category { Id = 2, Name = "Film", Description = "Film festivals and screenings", CreatedAt = fixedDate, IsActive = true },
                new Category { Id = 3, Name = "Gaming", Description = "Gaming and esports festivals", CreatedAt = fixedDate, IsActive = true }
            );

            // Seed Subcategories
            modelBuilder.Entity<Subcategory>().HasData(
                // Music subcategories
                new Subcategory { Id = 1, Name = "Jazz", Description = "Jazz music festivals", CategoryId = 1, CreatedAt = fixedDate, IsActive = true },
                new Subcategory { Id = 2, Name = "Rock", Description = "Rock music festivals", CategoryId = 1, CreatedAt = fixedDate, IsActive = true },
                new Subcategory { Id = 3, Name = "Classical", Description = "Classical music festivals", CategoryId = 1, CreatedAt = fixedDate, IsActive = true },
                // Film subcategories
                new Subcategory { Id = 4, Name = "Feature", Description = "Feature film festivals", CategoryId = 2, CreatedAt = fixedDate, IsActive = true },
                new Subcategory { Id = 5, Name = "Short", Description = "Short film festivals", CategoryId = 2, CreatedAt = fixedDate, IsActive = true },
                new Subcategory { Id = 6, Name = "Documentary", Description = "Documentary film festivals", CategoryId = 2, CreatedAt = fixedDate, IsActive = true },
                // Gaming subcategories
                new Subcategory { Id = 7, Name = "Esports", Description = "Esports tournaments and festivals", CategoryId = 3, CreatedAt = fixedDate, IsActive = true },
                new Subcategory { Id = 8, Name = "Indie", Description = "Indie game festivals", CategoryId = 3, CreatedAt = fixedDate, IsActive = true },
                new Subcategory { Id = 9, Name = "Retro", Description = "Retro gaming festivals", CategoryId = 3, CreatedAt = fixedDate, IsActive = true }
            );

            // Seed Organizers
            modelBuilder.Entity<Organizer>().HasData(
                new Organizer { Id = 1, Name = "Global Events Ltd.", ContactInfo = "contact@globalevents.com", CreatedAt = fixedDate, IsActive = true },
                new Organizer { Id = 2, Name = "Festival Makers", ContactInfo = "+123456789", CreatedAt = fixedDate, IsActive = true },
                new Organizer { Id = 3, Name = "Cannes Organizing Committee", ContactInfo = "info@cannesfestival.com", CreatedAt = fixedDate, IsActive = true },
                new Organizer { Id = 4, Name = "Sundance Institute", ContactInfo = "info@sundance.org", CreatedAt = fixedDate, IsActive = true },
                new Organizer { Id = 5, Name = "Entertainment Software Association (ESA)", ContactInfo = "info@theesa.com", CreatedAt = fixedDate, IsActive = true },
                new Organizer { Id = 6, Name = "Riot Games", ContactInfo = "events@riotgames.com", CreatedAt = fixedDate, IsActive = true }
            );

            // Use static future dates for festivals (set to dates well into the future for long-term testing validity)
            // These dates are set to be in 2025/2026 to ensure they remain future dates for testing
            var baseStartDate = new DateTime(2025, 9, 1, 0, 0, 0, DateTimeKind.Utc);
            
            // Seed Festivals (2 music, 2 film, 2 gaming) with real coordinates and future dates
            modelBuilder.Entity<Festival>().HasData(
                // Music
                new Festival { Id = 1, Title = "Sarajevo Jazz Nights", StartDate = baseStartDate.AddDays(15), EndDate = baseStartDate.AddDays(19), BasePrice = 49.99m, Location = "43.8563,18.4131", CreatedAt = fixedDate, IsActive = true, CityId = 1, SubcategoryId = 1, OrganizerId = 1 }, // Sarajevo - June 16-20, 2025
                new Festival { Id = 2, Title = "Mostar Rock Fest", StartDate = baseStartDate.AddDays(40), EndDate = baseStartDate.AddDays(42), BasePrice = 39.50m, Location = "43.3438,17.8078", CreatedAt = fixedDate, IsActive = true, CityId = 5, SubcategoryId = 2, OrganizerId = 2 }, // Mostar - July 11-13, 2025

                // Film
                new Festival { Id = 3, Title = "Cannes Film Festival", StartDate = baseStartDate.AddDays(70), EndDate = baseStartDate.AddDays(81), BasePrice = 99.00m, Location = "43.552847,7.017369", CreatedAt = fixedDate, IsActive = true, CityId = 12, SubcategoryId = 4, OrganizerId = 3 }, // Cannes, France - Aug 10-21, 2025
                new Festival { Id = 4, Title = "Sundance Film Festival", StartDate = baseStartDate.AddDays(25), EndDate = baseStartDate.AddDays(35), BasePrice = 79.00m, Location = "40.6461,-111.4980", CreatedAt = fixedDate, IsActive = true, CityId = 26, SubcategoryId = 4, OrganizerId = 4 }, // Park City, Utah, USA - June 26 - July 6, 2025

                // Gaming
                new Festival { Id = 5, Title = "E3 (Electronic Entertainment Expo)", StartDate = baseStartDate.AddDays(55), EndDate = baseStartDate.AddDays(57), BasePrice = 59.00m, Location = "34.0522,-118.2437", CreatedAt = fixedDate, IsActive = true, CityId = 17, SubcategoryId = 8, OrganizerId = 5 }, // Los Angeles, USA - July 26-28, 2025
                new Festival { Id = 6, Title = "LEC Finals", StartDate = baseStartDate.AddDays(120), EndDate = baseStartDate.AddDays(122), BasePrice = 45.00m, Location = "50.9375,6.9603", CreatedAt = fixedDate, IsActive = true, CityId = 27, SubcategoryId = 7, OrganizerId = 6 } // Cologne, Germany - Aug 30-31, 2025
            );

            // Country Seeding
            modelBuilder.Entity<Country>().HasData(
                new Country { Id = 1, Name = "Bosnia and Herzegovina", Flag = ImageConversion.ConvertImageToByteArray("Assets", "bih.png") },
                new Country { Id = 2, Name = "France", Flag = ImageConversion.ConvertImageToByteArray("Assets", "fra.png") },
                new Country { Id = 3, Name = "Germany", Flag = ImageConversion.ConvertImageToByteArray("Assets", "ger.png") },
                new Country { Id = 4, Name = "United States", Flag = ImageConversion.ConvertImageToByteArray("Assets", "usa.png") },
                new Country { Id = 5, Name = "Spain", Flag = ImageConversion.ConvertImageToByteArray("Assets", "spa.png") },
                new Country { Id = 6, Name = "United Kingdom", Flag = ImageConversion.ConvertImageToByteArray("Assets", "uk.png") }
            );

            // City Seeding
            modelBuilder.Entity<City>().HasData(
                // Bosnia and Herzegovina
                new City { Id = 1, Name = "Sarajevo", CountryId = 1 },
                new City { Id = 2, Name = "Banja Luka", CountryId = 1 },
                new City { Id = 3, Name = "Tuzla", CountryId = 1 },
                new City { Id = 4, Name = "Zenica", CountryId = 1 },
                new City { Id = 5, Name = "Mostar", CountryId = 1 },
                new City { Id = 6, Name = "Bijeljina", CountryId = 1 },
                new City { Id = 7, Name = "Prijedor", CountryId = 1 },
                new City { Id = 8, Name = "Brčko", CountryId = 1 },
                new City { Id = 9, Name = "Doboj", CountryId = 1 },
                new City { Id = 10, Name = "Zvornik", CountryId = 1 },

                // France
                new City { Id = 11, Name = "Paris", CountryId = 2 },
                new City { Id = 12, Name = "Cannes", CountryId = 2 },
                new City { Id = 13, Name = "Nice", CountryId = 2 },

                // Germany
                new City { Id = 14, Name = "Berlin", CountryId = 3 },
                new City { Id = 15, Name = "Munich", CountryId = 3 },
                new City { Id = 16, Name = "Hamburg", CountryId = 3 },
                new City { Id = 27, Name = "Cologne", CountryId = 3 },

                // United States
                new City { Id = 17, Name = "Los Angeles", CountryId = 4 },
                new City { Id = 18, Name = "New York", CountryId = 4 },
                new City { Id = 19, Name = "Chicago", CountryId = 4 },
                new City { Id = 26, Name = "Park City", CountryId = 4 },

                // Spain
                new City { Id = 20, Name = "Madrid", CountryId = 5 },
                new City { Id = 21, Name = "Barcelona", CountryId = 5 },
                new City { Id = 22, Name = "San Sebastian", CountryId = 5 },

                // United Kingdom
                new City { Id = 23, Name = "London", CountryId = 6 },
                new City { Id = 24, Name = "Edinburgh", CountryId = 6 },
                new City { Id = 25, Name = "Manchester", CountryId = 6 }
            );

            // Seed Assets (two images per festival)
            modelBuilder.Entity<Asset>().HasData(
                // Sarajevo Jazz Nights
                new Asset { Id = 1, FileName = "Jazz1.png", ContentType = "image/png", Base64Content = ImageConversion.ConvertImageToBase64String("Assets", "Jazz1.png"), CreatedAt = fixedDate, FestivalId = 1 },
                new Asset { Id = 2, FileName = "Jazz2.png", ContentType = "image/png", Base64Content = ImageConversion.ConvertImageToBase64String("Assets", "Jazz2.png"), CreatedAt = fixedDate, FestivalId = 1 },

                // Mostar Rock Fest
                new Asset { Id = 3, FileName = "Rock1.png", ContentType = "image/png", Base64Content = ImageConversion.ConvertImageToBase64String("Assets", "Rock1.png"), CreatedAt = fixedDate, FestivalId = 2 },
                new Asset { Id = 4, FileName = "Rock2.png", ContentType = "image/png", Base64Content = ImageConversion.ConvertImageToBase64String("Assets", "Rock2.png"), CreatedAt = fixedDate, FestivalId = 2 },

                // Cannes Film Festival
                new Asset { Id = 5, FileName = "Cannes1.png", ContentType = "image/png", Base64Content = ImageConversion.ConvertImageToBase64String("Assets", "Cannes1.png"), CreatedAt = fixedDate, FestivalId = 3 },
                new Asset { Id = 6, FileName = "Cannes2.png", ContentType = "image/png", Base64Content = ImageConversion.ConvertImageToBase64String("Assets", "Cannes2.png"), CreatedAt = fixedDate, FestivalId = 3 },

                // Sundance Film Festival
                new Asset { Id = 7, FileName = "Sundance1.png", ContentType = "image/png", Base64Content = ImageConversion.ConvertImageToBase64String("Assets", "Sundance1.png"), CreatedAt = fixedDate, FestivalId = 4 },
                new Asset { Id = 8, FileName = "Sundance2.png", ContentType = "image/png", Base64Content = ImageConversion.ConvertImageToBase64String("Assets", "Sundance2.png"), CreatedAt = fixedDate, FestivalId = 4 },

                // E3
                new Asset { Id = 9, FileName = "E3_1.png", ContentType = "image/png", Base64Content = ImageConversion.ConvertImageToBase64String("Assets", "E3_1.png"), CreatedAt = fixedDate, FestivalId = 5 },
                new Asset { Id = 10, FileName = "E3_2.png", ContentType = "image/png", Base64Content = ImageConversion.ConvertImageToBase64String("Assets", "E3_2.png"), CreatedAt = fixedDate, FestivalId = 5 },

                // LEC Finals
                new Asset { Id = 11, FileName = "LEC1.png", ContentType = "image/png", Base64Content = ImageConversion.ConvertImageToBase64String("Assets", "LEC1.png"), CreatedAt = fixedDate, FestivalId = 6 },
                new Asset { Id = 12, FileName = "LEC2.png", ContentType = "image/png", Base64Content = ImageConversion.ConvertImageToBase64String("Assets", "LEC2.png"), CreatedAt = fixedDate, FestivalId = 6 }
            );

            // Seed Reviews
            modelBuilder.Entity<Review>().HasData(
                // User 4 reviews every festival
                new Review { Id = 1, FestivalId = 1, UserId = 4, Rating = 5, Comment = "Amazing jazz performances and great atmosphere!", CreatedAt = fixedDate },
                new Review { Id = 3, FestivalId = 3, UserId = 4, Rating = 5, Comment = "World-class premieres at Cannes!", CreatedAt = fixedDate },
                new Review { Id = 6, FestivalId = 6, UserId = 4, Rating = 5, Comment = "LEC Finals were electric!", CreatedAt = fixedDate },

                // User 2 reviews a few festivals (not all)
                new Review { Id = 7, FestivalId = 1, UserId = 2, Rating = 4, Comment = "Loved the outdoor stages.", CreatedAt = fixedDate },
                new Review { Id = 8, FestivalId = 3, UserId = 2, Rating = 5, Comment = "Cannes never disappoints.", CreatedAt = fixedDate },
                new Review { Id = 9, FestivalId = 6, UserId = 2, Rating = 4, Comment = "Incredible finals weekend!", CreatedAt = fixedDate }
            );

            // Seed Ticket Types
            modelBuilder.Entity<TicketType>().HasData(
                new TicketType { Id = 1, Name = "Standard", Description = "Standard access", PriceMultiplier = 1.0m, CreatedAt = fixedDate, IsActive = true },
                new TicketType { Id = 2, Name = "VIP", Description = "VIP access with perks", PriceMultiplier = 1.5m, CreatedAt = fixedDate, IsActive = true },
                new TicketType { Id = 3, Name = "Student", Description = "Student discount", PriceMultiplier = 0.8m, CreatedAt = fixedDate, IsActive = true }
            );

            // Seed Tickets for users 4 and 2 (final price precomputed)
            modelBuilder.Entity<Ticket>().HasData(
                // User 4
                new Ticket { Id = 1, FestivalId = 1, UserId = 4, TicketTypeId = 1, FinalPrice = 49.99m, GeneratedCode = "F1D-U4S-STD", IsRedeemed = true, CreatedAt = fixedDate },
                new Ticket { Id = 2, FestivalId = 3, UserId = 4, TicketTypeId = 2, FinalPrice = 148.50m, GeneratedCode = "F3D-T4E-VIP", IsRedeemed = true, CreatedAt = fixedDate },
                new Ticket { Id = 3, FestivalId = 6, UserId = 4, TicketTypeId = 3, FinalPrice = 36.00m, GeneratedCode = "F6D-U4S-STU", IsRedeemed = true, CreatedAt = fixedDate },

                // User 2 (match their reviews on festivals 1, 3, and 6)
                new Ticket { Id = 4, FestivalId = 1, UserId = 2, TicketTypeId = 1, FinalPrice = 49.99m, GeneratedCode = "F1D-K2S-STD", IsRedeemed = true, CreatedAt = fixedDate },
                new Ticket { Id = 5, FestivalId = 3, UserId = 2, TicketTypeId = 2, FinalPrice = 148.50m, GeneratedCode = "F3D-U2E-VIP", IsRedeemed = true, CreatedAt = fixedDate },
                new Ticket { Id = 6, FestivalId = 6, UserId = 2, TicketTypeId = 3, FinalPrice = 36.00m, GeneratedCode = "F6D-L2S-STU", IsRedeemed = true, CreatedAt = fixedDate }
            );
        }
    }
} 