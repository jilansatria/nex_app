import os
import glob
import re

models_path = r"d:\nex_backend\app\models\*.py"

for filepath in glob.glob(models_path):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace the postgresql import
    content = content.replace("from sqlalchemy.dialects.postgresql import UUID", "from sqlalchemy import Uuid as UUID")
    content = content.replace("from sqlalchemy.dialects.postgresql import UUID, JSON", "from sqlalchemy import Uuid as UUID, JSON")
    
    # We mapped Uuid to UUID so the `UUID(as_uuid=True)` still works, no need to touch the declarative lines!
    # Wait, actually let's just make it simpler: `from sqlalchemy import Uuid` and change `UUID(as_uuid=True)` to `Uuid(as_uuid=True)`
    # Let's replace the import correctly
    content = re.sub(r'from sqlalchemy\.dialects\.postgresql import UUID(, JSON)?', 
                     lambda m: 'from sqlalchemy import Uuid, JSON' if m.group(1) else 'from sqlalchemy import Uuid', 
                     content)
    
    # Replace UUID(as_uuid=... with Uuid(as_uuid=...
    content = content.replace("UUID(as_uuid=True)", "Uuid(as_uuid=True)")
    content = content.replace("UUID(as_uuid=False)", "Uuid(as_uuid=False)")
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

print("Modification complete.")
