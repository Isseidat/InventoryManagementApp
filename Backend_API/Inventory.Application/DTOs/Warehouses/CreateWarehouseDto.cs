namespace Inventory.Application.DTOs.Warehouses
{
    public class CreateWarehouseDto
    {
        public string Name { get; set; } = string.Empty;
        public string? Location { get; set; }
    }
}
