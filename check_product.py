
from app.core.database import SessionLocal
from app.crud import product

db = SessionLocal()
p = product.get_by_name(db, name="Sawit Mentah")
if p:
    print(f"Found: {p.name} (ID: {p.id})")
else:
    print("Not Found: Sawit Mentah")

# List all products just in case
all_p = product.get_multi(db)
print("\nAll Products:")
for item in all_p:
    print(f"- {item.name}")
