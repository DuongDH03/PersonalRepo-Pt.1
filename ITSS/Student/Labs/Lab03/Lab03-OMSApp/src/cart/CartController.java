package cart;

import com.oms.bean.Order;
import com.oms.bean.OrderLine;

public class CartController {
	private CartPane cartPane;
	private CartDialog dialog;
	private Order order;
	
	public CartController() {
		order = new Order();
		dialog = new CartDialog();
		cartPane = new CartPane();
		
		cartPane.setController(this);
		dialog.setController(this);
		
		updateCartPane();
	}
	
	private void updateCartPane() {
		cartPane.updateData(getPresentationText());
	}
	
	private String getPresentationText() {
		int numberOfItems = 0;
		if ( order.getOrderLines() != null) {
			numberOfItems = order.getOrderLines().size();
		}
		return "Your cart has " + numberOfItems + " products. Total Cost: " + order.getTotalCost();
	}
	
	public CartPane getCartPane() {
		return cartPane;
	}
	
	public void showCartDialog() {
		dialog.setVisible(true);
	}
	
	public void addToCart(String productId, String productTitle, float productCost, int productQuantity) {
		order.addOrderLine(new OrderLine(productId, productTitle, productQuantity, productCost));
		
		dialog.updateData(order);
		updateCartPane();
	}
	
	public void checkOut() {
		System.out.println("Checkout!!!");
	}
	
	public void setOrderLineQuantity(OrderLine orderLine, int quantity) {
		for (OrderLine ol: order.getOrderLines()) {
			if (ol == orderLine) {
				if (quantity == 0) {
					order.getOrderLines().remove(ol);
					break;
				}
				ol.setProductQuantity(quantity);
			}
		}
		
		updateCartPane();
	}
}
