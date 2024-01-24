from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
from typing import Optional

# Dodaj odpowiednie importy dla make_transaction, model i scaler
from Polecenia import make_transaction, scaler
model = joblib.load('final_logreg_model.pkl')
app = FastAPI()

class TransactionRequest(BaseModel):
    source_account: str
    target_account: str
    amount: float

@app.post("/make_transaction_api")
def make_transaction_api(request: TransactionRequest):
    # Kod funkcji make_transaction musi być dostępny tutaj
    result = make_transaction(request.source_account, request.target_account, request.amount, model, scaler)
    if result is not None:
        raise HTTPException(status_code=400, detail=result)

    return {"status": "success", "message": f"Transakcja pomiędzy kontami {request.source_account} i {request.target_account} zakończona."}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
