using ManiFest.Services.Helpers;
using Microsoft.EntityFrameworkCore;
using System;

namespace ManiFest.Services.Database
{
    public static class DataSeeder
    {
        private const string DefaultPhoneNumber = "+387 00 000 000";
        
        private const string TestMailSender = "test.sender@gmail.com";
        private const string TestMailReceiver = "test.receiver@gmail.com";

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

            // Seed Countries
            modelBuilder.Entity<Country>().HasData(
                new Country { Id = 1, Name = "Bosnia and Herzegovina" },
                new Country { Id = 2, Name = "Croatia" },
                new Country { Id = 3, Name = "Serbia" },
                new Country { Id = 4, Name = "Montenegro" },
                new Country { Id = 5, Name = "North Macedonia" },
                new Country { Id = 6, Name = "France" },
                new Country { Id = 7, Name = "Germany" },
                new Country { Id = 8, Name = "Italy" },
                new Country { Id = 9, Name = "Spain" },
                new Country { Id = 10, Name = "United Kingdom" }
            );

            // Seed Users
            modelBuilder.Entity<User>().HasData(
                new User 
                {
                    Id = 1,
                    FirstName = "Denis",
                    LastName = "Mušić",
                    Email = TestMailReceiver,
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
                    Email = "example1@gmail.com",
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
                    FirstName = "Test", 
                    LastName = "Test", 
                    Email = TestMailSender, 
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
                new UserRole { Id = 2, UserId = 2, RoleId = 1, DateAssigned = fixedDate }, 
                new UserRole { Id = 3, UserId = 3, RoleId = 2, DateAssigned = fixedDate }, 
                new UserRole { Id = 4, UserId = 4, RoleId = 2, DateAssigned = fixedDate }  
            );

            // Seed Genders
            modelBuilder.Entity<Gender>().HasData(
                new Gender { Id = 1, Name = "Male" },
                new Gender { Id = 2, Name = "Female" }
            );

            // Seed Cities
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
                
                // Croatia
                new City { Id = 11, Name = "Zagreb", CountryId = 2 },
                new City { Id = 12, Name = "Split", CountryId = 2 },
                new City { Id = 13, Name = "Rijeka", CountryId = 2 },
                
                // Serbia
                new City { Id = 14, Name = "Beograd", CountryId = 3 },
                new City { Id = 15, Name = "Novi Sad", CountryId = 3 },
                new City { Id = 16, Name = "Niš", CountryId = 3 },
                
                // Montenegro
                new City { Id = 17, Name = "Podgorica", CountryId = 4 },
                new City { Id = 18, Name = "Budva", CountryId = 4 },
                new City { Id = 19, Name = "Kotor", CountryId = 4 },
                
                // North Macedonia
                new City { Id = 20, Name = "Skopje", CountryId = 5 },
                new City { Id = 21, Name = "Bitola", CountryId = 5 },
                new City { Id = 22, Name = "Ohrid", CountryId = 5 },
                
                // France - Famous for Cannes Film Festival, Nice Jazz Festival, etc.
                new City { Id = 23, Name = "Paris", CountryId = 6 },
                new City { Id = 24, Name = "Cannes", CountryId = 6 },
                new City { Id = 25, Name = "Nice", CountryId = 6 },
                
                // Germany - Famous for Berlinale, Rock am Ring, etc.
                new City { Id = 26, Name = "Berlin", CountryId = 7 },
                new City { Id = 27, Name = "Munich", CountryId = 7 },
                new City { Id = 28, Name = "Hamburg", CountryId = 7 },
                
                // Italy - Famous for Venice Film Festival, Sanremo Music Festival, etc.
                new City { Id = 29, Name = "Rome", CountryId = 8 },
                new City { Id = 30, Name = "Venice", CountryId = 8 },
                new City { Id = 31, Name = "Milan", CountryId = 8 },
                
                // Spain - Famous for San Sebastian Film Festival, Primavera Sound, etc.
                new City { Id = 32, Name = "Madrid", CountryId = 9 },
                new City { Id = 33, Name = "Barcelona", CountryId = 9 },
                new City { Id = 34, Name = "San Sebastian", CountryId = 9 },
                
                // United Kingdom - Famous for Glastonbury, Edinburgh Festival, etc.
                new City { Id = 35, Name = "London", CountryId = 10 },
                new City { Id = 36, Name = "Edinburgh", CountryId = 10 },
                new City { Id = 37, Name = "Manchester", CountryId = 10 }
            );
        }
    }
} 