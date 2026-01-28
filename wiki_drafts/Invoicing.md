# Invoicing Guide

Creating professional invoices is the core feature of InvoBharat. This guide covers how to create, manage, and print invoices.

## 🧾 Creating a New Invoice

1.  Navigate to the **Invoices** tab from the sidebar.
2.  Click the **+ New Invoice** button.

### Step 1: Client Selection
*   **Select Client**: Choose an existing client from the dropdown.
*   **Add New**: If it's a new client, click the "+" icon to add them instantly (See [[Client Management]]).
*   **Auto-Fill**: Once selected, the client's Address and GSTIN are automatically populated.
*   **Place of Supply**: Verified automatically. If Client State != Business State, **IGST** is applied. Otherwise, **CGST + SGST** is applied.

### Step 2: Invoice Details
*   **Invoice #**: Auto-incremented (e.g., INV-001) but customizable.
*   **Date**: Defaults to today.
*   **Due Date**: Set a payment deadline.

### Step 3: Adding Items
*   **Add Item**: Select products/services from your Inventory or type a new one manually.
*   **Quantity & Price**: Enter the specific quantity and rate.
*   **Discount**: Apply a discount percentage or fixed amount per item if needed.
*   **Tax**: Select the tax slab (e.g., 18%). The system automatically splits this into SGST/CGST or keeps it as IGST based on the client.

### Step 4: Notes and Terms
*   **Notes**: Add a personal note (e.g., "Thanks for your business!").
*   **Terms**: Payment terms (e.g., "Payment due within 7 days").

### Step 5: Save & Actions
Click **Save**. You will be redirected to the Invoice Preview.

## 🖨️ Invoice Actions

Once saved, you can:
*   **Print**: Send directly to your printer.
*   **PDF**: Save as a High-Quality PDF.
*   **Duplicate**: Create a copy of this invoice (useful for repeat orders).
*   **Cancel**: Mark the invoice as void without deleting the record (good for audit trails).
*   **Mark as Paid/Unpaid**: Track payment status.

## 🔄 Recurring Invoices
For clients you bill regularly (e.g., monthly retainers):
1.  Go to **Recurring Invoices** tab.
2.  Create a profile similar to a normal invoice.
3.  Set the **Frequency** (Monthly, Quarterly, Annually).
4.  InvoBharat will remind you or auto-generate these invoices.

---
**Next**: Learn about [[Estimates]].
