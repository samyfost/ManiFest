using Microsoft.EntityFrameworkCore;

namespace ManiFest.Services.Database
{
    public class ManiFestDbContext : DbContext
    {
        public ManiFestDbContext(DbContextOptions<ManiFestDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<Gender> Genders { get; set; }
        public DbSet<City> Cities { get; set; }
        public DbSet<Country> Countries { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<Subcategory> Subcategories { get; set; }
        public DbSet<Organizer> Organizers { get; set; }
        public DbSet<Festival> Festivals { get; set; }
        public DbSet<Asset> Assets { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<TicketType> TicketTypes { get; set; }
        public DbSet<Ticket> Tickets { get; set; }
    

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure User entity
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();
               

            // Configure Role entity
            modelBuilder.Entity<Role>()
                .HasIndex(r => r.Name)
                .IsUnique();

            // Configure UserRole join entity
            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.Role)
                .WithMany(r => r.UserRoles)
                .HasForeignKey(ur => ur.RoleId)
                .OnDelete(DeleteBehavior.Cascade);

            // Create a unique constraint on UserId and RoleId
            modelBuilder.Entity<UserRole>()
                .HasIndex(ur => new { ur.UserId, ur.RoleId })
                .IsUnique();

         

            // Configure Gender entity
            modelBuilder.Entity<Gender>()
                .HasIndex(g => g.Name)
                .IsUnique();

            // Configure Country entity
            modelBuilder.Entity<Country>()
                .HasIndex(c => c.Name)
                .IsUnique();

            // Configure City entity
            modelBuilder.Entity<City>()
                .HasIndex(c => new { c.Name, c.CountryId })
                .IsUnique();

            modelBuilder.Entity<City>()
                .HasOne(c => c.Country)
                .WithMany()
                .HasForeignKey(c => c.CountryId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<User>()
                .HasOne(u => u.Gender)
                .WithMany()
                .HasForeignKey(u => u.GenderId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<User>()
                .HasOne(u => u.City)
                .WithMany()
                .HasForeignKey(u => u.CityId)
                .OnDelete(DeleteBehavior.NoAction);

            // Configure Category entity
            modelBuilder.Entity<Category>()
                .HasIndex(c => c.Name)
                .IsUnique();

            // Configure Subcategory entity
            modelBuilder.Entity<Subcategory>()
                .HasIndex(s => new { s.Name, s.CategoryId })
                .IsUnique();

            modelBuilder.Entity<Subcategory>()
                .HasOne(s => s.Category)
                .WithMany(c => c.Subcategories)
                .HasForeignKey(s => s.CategoryId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure Organizer entity
            modelBuilder.Entity<Organizer>()
                .HasIndex(o => o.Name)
                .IsUnique();

            // Configure Festival entity
            modelBuilder.Entity<Festival>()
                .HasOne(f => f.City)
                .WithMany()
                .HasForeignKey(f => f.CityId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Festival>()
                .HasOne(f => f.Subcategory)
                .WithMany()
                .HasForeignKey(f => f.SubcategoryId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Festival>()
                .HasOne(f => f.Organizer)
                .WithMany(o => o.Festivals)
                .HasForeignKey(f => f.OrganizerId)
                .OnDelete(DeleteBehavior.NoAction);

            // Configure Asset entity
            modelBuilder.Entity<Asset>()
                .HasOne(a => a.Festival)
                .WithMany(f => f.Assets)
                .HasForeignKey(a => a.FestivalId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure Review entity
            modelBuilder.Entity<Review>()
                .HasOne(r => r.Festival)
                .WithMany()
                .HasForeignKey(r => r.FestivalId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Review>()
                .HasOne(r => r.User)
                .WithMany()
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Review>()
                .HasIndex(r => new { r.FestivalId, r.UserId });

            // Configure Ticket and TicketType
            modelBuilder.Entity<TicketType>()
                .HasIndex(tt => tt.Name)
                .IsUnique();

            modelBuilder.Entity<Ticket>()
                .HasOne(t => t.Festival)
                .WithMany()
                .HasForeignKey(t => t.FestivalId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Ticket>()
                .HasOne(t => t.User)
                .WithMany()
                .HasForeignKey(t => t.UserId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Ticket>()
                .HasOne(t => t.TicketType)
                .WithMany()
                .HasForeignKey(t => t.TicketTypeId)
                .OnDelete(DeleteBehavior.NoAction);

      
            // Seed initial data
            modelBuilder.SeedData();
        }
    }
} 