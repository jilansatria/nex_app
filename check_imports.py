import sys
import os

sys.path.append(os.getcwd())

try:
    from app.models.sales import SalesShipment
    print("Success importing SalesShipment directly")
except Exception as e:
    import traceback
    traceback.print_exc()

try:
    from app.models.sales_contract import SalesContract
    print("Success importing SalesContract directly")
except Exception as e:
    import traceback
    traceback.print_exc()

try:
    from app.models import SalesShipment, SalesContract
    print("Success importing from app.models")
except Exception as e:
    import traceback
    traceback.print_exc()
