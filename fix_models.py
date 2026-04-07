import os
import glob
import re

models_path = r"d:\nex_backend\app\models\*.py"

for filepath in glob.glob(models_path):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Correct postgres imports
    content = re.sub(r"from sqlalchemy\.dialects\.postgresql import .*", "from sqlalchemy import Uuid, JSON", content)
    
    # Also replace old "import Uuid as UUID" if any left
    content = content.replace("from sqlalchemy import Uuid as UUID", "from sqlalchemy import Uuid")
    content = content.replace("from sqlalchemy import Uuid as UUID, JSON", "from sqlalchemy import Uuid, JSON")
    
    # Replace UUID(...) and Uuid(...) to Uuid(...)
    content = content.replace("UUID(as_uuid=True)", "Uuid(as_uuid=True)")
    content = content.replace("UUID(as_uuid=False)", "Uuid(as_uuid=False)")
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

print("Fixed models.")
