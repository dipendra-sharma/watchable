# Watchable - Complete Usage Guide

**Comprehensive examples and patterns for building Flutter apps with Watchable.**

> 💡 **New to Watchable?** Start with the [README](README.md) for a quick introduction.

This guide covers everything you need to build production Flutter apps using only `.watch` and `.value`:

## Table of Contents

1. [Single Watchable UI Rendering](#1-single-watchable-ui-rendering)
2. [Multi-Watchable Combiners](#2-multi-watchable-combiners-build)
3. [Combiner Functions (.combine)](#3-combiner-functions-combine---derived-state)
4. [Performance Optimization (shouldRebuild)](#4-shouldrebuild---performance-optimization)
5. [Complete Widget Examples](#5-complete-widget-examples)
6. [Real-World App Example](#6-real-world-complete-app-example)

# 1. 📱 **Single Watchable UI Rendering**

### Basic Text & Widgets
```dart
final message = 'Hello World'.watch;
final isLoading = false.watch;
final progress = 0.5.watch;

// Simple text
message.build((msg) => Text(msg))

// Loading indicator
isLoading.build((loading) => 
  loading ? CircularProgressIndicator() : Icon(Icons.check)
)

// Progress bar
progress.build((p) => LinearProgressIndicator(value: p))

// Styled widgets
message.build((msg) => Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text(msg, style: TextStyle(fontSize: 18)),
  ),
))
```

### Interactive Widgets
```dart
final sliderValue = 50.0.watch;
final switchValue = false.watch;
final selectedOption = 'Option 1'.watch;

// Slider
sliderValue.build((value) => Slider(
  value: value,
  min: 0,
  max: 100,
  onChanged: (newValue) => sliderValue.value = newValue,
))

// Switch
switchValue.build((isOn) => Switch(
  value: isOn,
  onChanged: (newValue) => switchValue.value = newValue,
))

// Dropdown
selectedOption.build((selected) => DropdownButton<String>(
  value: selected,
  items: ['Option 1', 'Option 2', 'Option 3'].map((option) => 
    DropdownMenuItem(value: option, child: Text(option))
  ).toList(),
  onChanged: (newValue) => selectedOption.value = newValue ?? selected,
))
```

### Conditional Rendering
```dart
final user = W<User?>(null);
final status = 'loading'.watch; // 'loading', 'success', 'error'

// Null safety
user.build((u) => u != null 
  ? UserCard(user: u) 
  : Text('No user logged in')
)

// Multiple conditions
status.build((s) {
  switch (s) {
    case 'loading': return CircularProgressIndicator();
    case 'success': return Icon(Icons.check, color: Colors.green);
    case 'error': return Icon(Icons.error, color: Colors.red);
    default: return Text('Unknown status');
  }
})

// Boolean conditions
final showDetails = false.watch;
showDetails.build((show) => AnimatedContainer(
  duration: Duration(milliseconds: 300),
  height: show ? 200 : 50,
  child: show ? DetailedView() : SummaryView(),
))
```

### List & Collection Rendering
```dart
final todos = <Todo>[].watch;
final users = <User>[].watch;
final categories = <String, List<Item>>{}.watch;

// Simple list
todos.build((todoList) => ListView.builder(
  itemCount: todoList.length,
  itemBuilder: (context, index) {
    final todo = todoList[index];
    return CheckboxListTile(
      title: Text(todo.title),
      value: todo.isCompleted,
      onChanged: (value) => toggleTodo(todo.id),
    );
  },
))

// Empty state handling
users.build((userList) {
  if (userList.isEmpty) {
    return Center(child: Text('No users found'));
  }
  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    itemCount: userList.length,
    itemBuilder: (context, index) => UserCard(userList[index]),
  );
})

// Complex nested data
categories.build((catMap) => ListView(
  children: catMap.entries.map((entry) => ExpansionTile(
    title: Text('${entry.key} (${entry.value.length})'),
    children: entry.value.map((item) => ListTile(
      title: Text(item.name),
      subtitle: Text('\$${item.price}'),
    )).toList(),
  )).toList(),
))
```

---

# 2. 🔗 **Multi-Watchable Combiners (.build)**

### 2 Watchables - Form Fields
```dart
final firstName = ''.watch;
final lastName = ''.watch;

// Name display
(firstName, lastName).build((first, last) => 
  Text('$first $last', style: TextStyle(fontSize: 24))
)

// Validation
(firstName, lastName).build((first, last) {
  final isValid = first.isNotEmpty && last.isNotEmpty;
  return Container(
    padding: EdgeInsets.all(8),
    color: isValid ? Colors.green.shade100 : Colors.red.shade100,
    child: Text(isValid ? 'Valid name' : 'Both fields required'),
  );
})
```

### 3 Watchables - Advanced Forms
```dart
final email = ''.watch;
final password = ''.watch;
final confirmPassword = ''.watch;

// Submit button with validation
(email, password, confirmPassword).build((e, p, cp) {
  final emailValid = e.contains('@');
  final passwordValid = p.length >= 6;
  final passwordsMatch = p == cp;
  final allValid = emailValid && passwordValid && passwordsMatch;
  
  return Column(
    children: [
      // Error messages
      if (!emailValid) Text('Invalid email', style: TextStyle(color: Colors.red)),
      if (!passwordValid) Text('Password too short', style: TextStyle(color: Colors.red)),
      if (!passwordsMatch) Text('Passwords don\'t match', style: TextStyle(color: Colors.red)),
      
      // Submit button
      ElevatedButton(
        onPressed: allValid ? () => submitForm(e, p) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: allValid ? Colors.green : Colors.grey,
        ),
        child: Text('Create Account'),
      ),
    ],
  );
})
```

### 4-6 Watchables - Complex UI
```dart
final width = 100.0.watch;
final height = 100.0.watch;
final color = Colors.blue.watch;
final rotation = 0.0.watch;

// Animated container with multiple properties
(width, height, color, rotation).build((w, h, c, r) => Transform.rotate(
  angle: r,
  child: AnimatedContainer(
    duration: Duration(milliseconds: 300),
    width: w,
    height: h,
    color: c,
    child: Center(child: Text('${w.toInt()}×${h.toInt()}')),
  ),
))

// Complex form with 6 fields
final street = ''.watch;
final city = ''.watch;
final state = ''.watch;
final zip = ''.watch;
final country = 'US'.watch;
final isDefault = false.watch;

(street, city, state, zip, country, isDefault).build((st, c, s, z, co, def) {
  final isComplete = st.isNotEmpty && c.isNotEmpty && s.isNotEmpty && z.isNotEmpty;
  
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Address ${def ? '(Default)' : ''}', 
               style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(st),
          Text('$c, $s $z'),
          Text(co),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: isComplete ? () => saveAddress(st, c, s, z, co, def) : null,
            child: Text(isComplete ? 'Save Address' : 'Complete All Fields'),
          ),
        ],
      ),
    ),
  );
})
```

---

# 3. ⚡ **Combiner Functions (.combine) - Derived State**

### Basic Calculations
```dart
final price = 100.0.watch;
final quantity = 2.watch;
final taxRate = 0.08.watch;

// Create derived watchables
final subtotal = (price, quantity).combine((p, q) => p * q);
final tax = (subtotal, taxRate).combine((sub, rate) => sub * rate);
final total = (subtotal, tax).combine((sub, t) => sub + t);

// Use derived watchables anywhere
subtotal.build((sub) => Text('Subtotal: \$${sub.toStringAsFixed(2)}'))
tax.build((t) => Text('Tax: \$${t.toStringAsFixed(2)}'))
total.build((tot) => Text('Total: \$${tot.toStringAsFixed(2)}', 
                         style: TextStyle(fontWeight: FontWeight.bold)))

// Chain combinations
final finalPrice = (total).combine((t) => t > 100 ? t * 0.9 : t); // 10% discount over $100
finalPrice.build((price) => Text('Final: \$${price.toStringAsFixed(2)}'))
```

### Search & Filtering
```dart
final allProducts = <Product>[].watch;
final searchQuery = ''.watch;
final selectedCategory = 'All'.watch;
final minPrice = 0.0.watch;
final maxPrice = 1000.0.watch;

// Create filtered results
final filteredProducts = (allProducts, searchQuery, selectedCategory, minPrice, maxPrice)
  .combine((products, query, category, minP, maxP) {
    return products.where((product) {
      final matchesSearch = query.isEmpty || 
        product.name.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == 'All' || product.category == category;
      final matchesPrice = product.price >= minP && product.price <= maxP;
      
      return matchesSearch && matchesCategory && matchesPrice;
    }).toList();
  });

// Use filtered results
filteredProducts.build((products) => Column(
  children: [
    Text('${products.length} products found'),
    Expanded(
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) => ProductCard(products[index]),
      ),
    ),
  ],
))

// Also create other derived state
final averagePrice = filteredProducts.combine((products) => 
  products.isEmpty ? 0.0 : 
  products.map((p) => p.price).reduce((a, b) => a + b) / products.length
);

averagePrice.build((avg) => Text('Average: \$${avg.toStringAsFixed(2)}'))
```

### Form Validation State
```dart
final username = ''.watch;
final email = ''.watch;
final password = ''.watch;
final confirmPassword = ''.watch;
final agreeTerms = false.watch;

// Create validation state
final usernameValid = username.combine((u) => u.length >= 3);
final emailValid = email.combine((e) => e.contains('@') && e.contains('.'));
final passwordValid = password.combine((p) => p.length >= 8 && p.contains(RegExp(r'[0-9]')));
final passwordsMatch = (password, confirmPassword).combine((p, cp) => p == cp && p.isNotEmpty);
final formValid = (usernameValid, emailValid, passwordValid, passwordsMatch, agreeTerms)
  .combine((uv, ev, pv, pm, terms) => uv && ev && pv && pm && terms);

// Use validation state throughout UI
usernameValid.build((valid) => Icon(valid ? Icons.check : Icons.error, 
                                   color: valid ? Colors.green : Colors.red))

emailValid.build((valid) => Container(
  padding: EdgeInsets.all(4),
  decoration: BoxDecoration(
    border: Border.all(color: valid ? Colors.green : Colors.red),
    borderRadius: BorderRadius.circular(4),
  ),
  child: TextField(
    onChanged: (value) => email.value = value,
    decoration: InputDecoration(labelText: 'Email'),
  ),
))

formValid.build((valid) => ElevatedButton(
  onPressed: valid ? submitForm : null,
  style: ElevatedButton.styleFrom(
    backgroundColor: valid ? Colors.green : Colors.grey,
  ),
  child: Text('Register'),
))
```

---

# 4. 🎯 **shouldRebuild - Performance Optimization**

### Expensive Widget Optimization
```dart
final userLocation = LatLng(37.7749, -122.4194).watch;
final stockPrice = 150.75.watch;
final chartData = <DataPoint>[].watch;

// Only rebuild map when location changes significantly
userLocation.build(
  (location) => ExpensiveMapWidget(
    center: location,
    markers: generateMarkers(location),
  ),
  shouldRebuild: (prev, current) {
    // Only rebuild if moved more than 0.001 degrees (~100 meters)
    final latDiff = (prev.latitude - current.latitude).abs();
    final lngDiff = (prev.longitude - current.longitude).abs();
    return latDiff > 0.001 || lngDiff > 0.001;
  },
)

// Only rebuild chart when price changes by $0.10 or more
stockPrice.build(
  (price) => ExpensiveStockChart(
    price: price,
    indicators: calculateIndicators(price),
  ),
  shouldRebuild: (prev, current) => (prev - current).abs() >= 0.10,
)

// Smart list rebuilds - only when items actually change
chartData.build(
  (data) => CustomPaint(
    painter: ChartPainter(data),
    size: Size(300, 200),
  ),
  shouldRebuild: (prevData, currentData) {
    if (prevData.length != currentData.length) return true;
    for (int i = 0; i < prevData.length; i++) {
      if (prevData[i].value != currentData[i].value) return true;
    }
    return false;
  },
)
```

### Threshold-Based Updates
```dart
final temperature = 22.5.watch;
final batteryLevel = 85.watch;
final downloadProgress = 0.0.watch;

// Only update when temperature changes by 0.5°C or more
temperature.build(
  (temp) => Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: temp > 25 ? Colors.red.shade100 : Colors.blue.shade100,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('${temp.toStringAsFixed(1)}°C'),
  ),
  shouldRebuild: (prev, current) => (prev - current).abs() >= 0.5,
)

// Only update battery indicator for 5% changes
batteryLevel.build(
  (level) => Row(
    children: [
      Icon(
        level > 20 ? Icons.battery_std : Icons.battery_alert,
        color: level > 20 ? Colors.green : Colors.red,
      ),
      Text('$level%'),
    ],
  ),
  shouldRebuild: (prev, current) => (prev - current).abs() >= 5,
)

// Smooth progress updates (only every 1%)
downloadProgress.build(
  (progress) => Column(
    children: [
      LinearProgressIndicator(value: progress),
      Text('${(progress * 100).toInt()}%'),
    ],
  ),
  shouldRebuild: (prev, current) => (prev - current).abs() >= 0.01,
)
```

### Multi-State shouldRebuild
```dart
final user = User().watch;
final preferences = UserPreferences().watch;
final theme = 'light'.watch;

// Only rebuild profile when name or avatar changes (ignore other fields)
(user, theme).build(
  (u, t) => ProfileHeader(
    user: u,
    isDarkMode: t == 'dark',
  ),
  shouldRebuild: (prevRecord, currentRecord) {
    final prevUser = prevRecord.$1;
    final currentUser = currentRecord.$1;
    final prevTheme = prevRecord.$2;
    final currentTheme = currentRecord.$2;
    
    // Only rebuild if name, avatar, or theme changed
    return prevUser.name != currentUser.name ||
           prevUser.avatarUrl != currentUser.avatarUrl ||
           prevTheme != currentTheme;
  },
)

// Complex form - only rebuild when validation state changes
(email, password, confirmPassword).build(
  (e, p, cp) => ValidationSummary(
    emailValid: e.contains('@'),
    passwordValid: p.length >= 6,
    passwordsMatch: p == cp,
  ),
  shouldRebuild: (prevRecord, currentRecord) {
    final prevEmailValid = prevRecord.$1.contains('@');
    final currentEmailValid = currentRecord.$1.contains('@');
    final prevPasswordValid = prevRecord.$2.length >= 6;
    final currentPasswordValid = currentRecord.$2.length >= 6;
    final prevPasswordsMatch = prevRecord.$2 == prevRecord.$3;
    final currentPasswordsMatch = currentRecord.$2 == currentRecord.$3;
    
    // Only rebuild if any validation state changed
    return prevEmailValid != currentEmailValid ||
           prevPasswordValid != currentPasswordValid ||
           prevPasswordsMatch != currentPasswordsMatch;
  },
)
```

---

# 5. 🧩 **Complete Widget Examples**

### Form Widget with All Features
```dart
class RegistrationForm extends StatelessWidget {
  // All state using .watch
  final firstName = ''.watch;
  final lastName = ''.watch;
  final email = ''.watch;
  final password = ''.watch;
  final confirmPassword = ''.watch;
  final acceptTerms = false.watch;
  
  // Derived validation state using .combine
  late final nameValid = (firstName, lastName).combine((f, l) => 
    f.length >= 2 && l.length >= 2);
  
  late final emailValid = email.combine((e) => 
    e.contains('@') && e.contains('.') && e.length > 5);
  
  late final passwordValid = password.combine((p) => 
    p.length >= 8 && p.contains(RegExp(r'[A-Z]')) && p.contains(RegExp(r'[0-9]')));
  
  late final passwordsMatch = (password, confirmPassword).combine((p, cp) => 
    p == cp && p.isNotEmpty);
  
  late final formValid = (nameValid, emailValid, passwordValid, passwordsMatch, acceptTerms)
    .combine((nv, ev, pv, pm, terms) => nv && ev && pv && pm && terms);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Name fields
          Row(
            children: [
              Expanded(child: TextField(
                onChanged: (value) => firstName.value = value,
                decoration: InputDecoration(labelText: 'First Name'),
              )),
              SizedBox(width: 16),
              Expanded(child: TextField(
                onChanged: (value) => lastName.value = value,
                decoration: InputDecoration(labelText: 'Last Name'),
              )),
            ],
          ),
          
          // Name validation with shouldRebuild optimization
          nameValid.build(
            (valid) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    valid ? Icons.check_circle : Icons.error,
                    color: valid ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    valid ? 'Name looks good' : 'Both names must be 2+ characters',
                    style: TextStyle(
                      color: valid ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            shouldRebuild: (prev, current) => prev != current, // Only rebuild when validation changes
          ),
          
          // Email field with real-time validation
          emailValid.build((valid) => TextField(
            onChanged: (value) => email.value = value,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: valid ? Colors.green : Colors.red),
              ),
              suffixIcon: Icon(
                valid ? Icons.check : Icons.error,
                color: valid ? Colors.green : Colors.red,
              ),
            ),
          )),
          
          SizedBox(height: 16),
          
          // Password fields
          TextField(
            onChanged: (value) => password.value = value,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
          ),
          
          SizedBox(height: 16),
          
          TextField(
            onChanged: (value) => confirmPassword.value = value,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Confirm Password'),
          ),
          
          // Password validation
          (passwordValid, passwordsMatch).build((pv, pm) => Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (pv && pm) ? Colors.green.shade50 : Colors.red.shade50,
              border: Border.all(
                color: (pv && pm) ? Colors.green : Colors.red,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(pv ? Icons.check : Icons.close, 
                         color: pv ? Colors.green : Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text('Password must be 8+ chars with uppercase and number'),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(pm ? Icons.check : Icons.close, 
                         color: pm ? Colors.green : Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text('Passwords must match'),
                  ],
                ),
              ],
            ),
          )),
          
          // Terms checkbox
          acceptTerms.build((accepted) => CheckboxListTile(
            value: accepted,
            onChanged: (value) => acceptTerms.value = value ?? false,
            title: Text('I accept the Terms and Conditions'),
          )),
          
          SizedBox(height: 24),
          
          // Submit button with form validation
          formValid.build(
            (valid) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: valid ? () => _submitForm(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: valid ? Colors.blue : Colors.grey,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  valid ? 'Create Account' : 'Please complete all fields',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            shouldRebuild: (prev, current) => prev != current, // Optimize button rebuilds
          ),
        ],
      ),
    );
  }
  
  void _submitForm(BuildContext context) {
    // Access current values directly
    print('Submitting: ${firstName.value} ${lastName.value}, ${email.value}');
    
    // Reset form
    firstName.value = '';
    lastName.value = '';
    email.value = '';
    password.value = '';
    confirmPassword.value = '';
    acceptTerms.value = false;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account created successfully!')),
    );
  }
}
```

### Shopping Cart Widget
```dart
class ShoppingCart extends StatelessWidget {
  // Core state
  final items = <CartItem>[].watch;
  final discountCode = ''.watch;
  final taxRate = 0.08.watch;
  final shippingAddress = W<Address?>(null);
  
  // Derived calculations using combiners
  late final itemCount = items.combine((list) => list.length);
  
  late final subtotal = items.combine((list) => 
    list.fold(0.0, (sum, item) => sum + (item.price * item.quantity)));
  
  late final discount = (subtotal, discountCode).combine((sub, code) {
    switch (code.toUpperCase()) {
      case 'SAVE10': return sub * 0.1;
      case 'SAVE20': return sub * 0.2;
      case 'WELCOME': return sub * 0.15;
      default: return 0.0;
    }
  });
  
  late final shipping = (subtotal, shippingAddress).combine((sub, address) {
    if (address == null) return 0.0;
    if (sub > 50) return 0.0; // Free shipping over $50
    return address.country == 'US' ? 5.99 : 12.99;
  });
  
  late final tax = (subtotal, discount, taxRate).combine((sub, disc, rate) => 
    (sub - disc) * rate);
  
  late final total = (subtotal, discount, shipping, tax).combine((sub, disc, ship, t) => 
    sub - disc + ship + t);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cart header with item count
        itemCount.build(
          (count) => Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.shopping_cart),
                SizedBox(width: 8),
                Text('Shopping Cart ($count items)', 
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          shouldRebuild: (prev, current) => prev != current, // Only rebuild when count changes
        ),
        
        // Cart items list
        Expanded(
          child: items.build((itemList) {
            if (itemList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                final item = itemList[index];
                return CartItemTile(
                  item: item,
                  onQuantityChanged: (newQuantity) => updateQuantity(item.id, newQuantity),
                  onRemove: () => removeItem(item.id),
                );
              },
            );
          }),
        ),
        
        // Discount code section
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                onChanged: (value) => discountCode.value = value,
                decoration: InputDecoration(
                  labelText: 'Discount Code',
                  border: OutlineInputBorder(),
                ),
              ),
              
              SizedBox(height: 8),
              
              // Discount validation
              discount.build(
                (discountAmount) => discountAmount > 0
                  ? Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Discount applied: -\$${discountAmount.toStringAsFixed(2)}',
                               style: TextStyle(color: Colors.green)),
                        ],
                      ),
                    )
                  : SizedBox(),
                shouldRebuild: (prev, current) => (prev > 0) != (current > 0), // Only rebuild when discount status changes
              ),
            ],
          ),
        ),
        
        // Cart summary
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            children: [
              // Subtotal
              subtotal.build(
                (sub) => _buildSummaryRow('Subtotal', '\$${sub.toStringAsFixed(2)}'),
                shouldRebuild: (prev, current) => (prev - current).abs() >= 0.01,
              ),
              
              // Discount (only show if > 0)
              discount.build((disc) => disc > 0 
                ? _buildSummaryRow('Discount', '-\$${disc.toStringAsFixed(2)}', Colors.green)
                : SizedBox()
              ),
              
              // Shipping
              shipping.build((ship) => ship > 0 
                ? _buildSummaryRow('Shipping', '\$${ship.toStringAsFixed(2)}')
                : _buildSummaryRow('Shipping', 'FREE', Colors.green)
              ),
              
              // Tax
              tax.build((t) => _buildSummaryRow('Tax', '\$${t.toStringAsFixed(2)}')),
              
              Divider(),
              
              // Total
              total.build(
                (tot) => _buildSummaryRow(
                  'Total', 
                  '\$${tot.toStringAsFixed(2)}',
                  null,
                  isTotal: true,
                ),
                shouldRebuild: (prev, current) => (prev - current).abs() >= 0.01,
              ),
              
              SizedBox(height: 16),
              
              // Checkout button
              total.build(
                (tot) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: tot > 0 ? () => checkout(context) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Checkout (\$${tot.toStringAsFixed(2)})',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                shouldRebuild: (prev, current) => (prev - current).abs() >= 0.01,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSummaryRow(String label, String value, [Color? valueColor, bool isTotal = false]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
  
  void updateQuantity(String itemId, int newQuantity) {
    items.value = items.value.map((item) => 
      item.id == itemId ? item.copyWith(quantity: newQuantity) : item
    ).toList();
  }
  
  void removeItem(String itemId) {
    items.value = items.value.where((item) => item.id != itemId).toList();
  }
  
  void checkout(BuildContext context) {
    // Navigate to checkout with current total
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => CheckoutPage(total: total.value),
    ));
  }
}
```

---

# 6. 🎪 **Real-World Complete App Example**

### Todo App with All Features
```dart
class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      home: TodoHomePage(),
    );
  }
}

class TodoHomePage extends StatelessWidget {
  // All app state using .watch
  final todos = <Todo>[].watch;
  final newTodoText = ''.watch;
  final filter = TodoFilter.all.watch; // all, active, completed
  final searchQuery = ''.watch;
  
  // Derived state using combiners
  late final filteredTodos = (todos, filter, searchQuery).combine((todoList, f, query) {
    var filtered = todoList;
    
    // Apply filter
    switch (f) {
      case TodoFilter.active:
        filtered = filtered.where((todo) => !todo.isCompleted).toList();
        break;
      case TodoFilter.completed:
        filtered = filtered.where((todo) => todo.isCompleted).toList();
        break;
      case TodoFilter.all:
        break;
    }
    
    // Apply search
    if (query.isNotEmpty) {
      filtered = filtered.where((todo) => 
        todo.title.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    
    return filtered;
  });
  
  late final activeCount = todos.combine((list) => 
    list.where((todo) => !todo.isCompleted).length);
  
  late final completedCount = todos.combine((list) => 
    list.where((todo) => todo.isCompleted).length);
  
  late final allCompleted = todos.combine((list) => 
    list.isNotEmpty && list.every((todo) => todo.isCompleted));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
        actions: [
          // Clear completed button - only show if there are completed todos
          completedCount.build((count) => count > 0 
            ? IconButton(
                icon: Icon(Icons.clear_all),
                onPressed: clearCompleted,
                tooltip: 'Clear $count completed',
              )
            : SizedBox()
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Add todo section
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Toggle all button
                allCompleted.build(
                  (allDone) => IconButton(
                    icon: Icon(
                      allDone ? Icons.check_box : Icons.check_box_outline_blank,
                      color: allDone ? Colors.green : Colors.grey,
                    ),
                    onPressed: toggleAll,
                  ),
                  shouldRebuild: (prev, current) => prev != current,
                ),
                
                // New todo input
                Expanded(
                  child: TextField(
                    onChanged: (value) => newTodoText.value = value,
                    onSubmitted: (value) => addTodo(),
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                
                SizedBox(width: 8),
                
                // Add button - only enabled when text is not empty
                newTodoText.build((text) => ElevatedButton(
                  onPressed: text.trim().isNotEmpty ? addTodo : null,
                  child: Icon(Icons.add),
                )),
              ],
            ),
          ),
          
          // Search bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) => searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search todos...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Filter tabs
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: filter.build((currentFilter) => Row(
              children: TodoFilter.values.map((f) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () => filter.value = f,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentFilter == f ? Colors.blue : Colors.grey.shade200,
                      foregroundColor: currentFilter == f ? Colors.white : Colors.black,
                    ),
                    child: Text(_getFilterName(f)),
                  ),
                ),
              )).toList(),
            )),
          ),
          
          SizedBox(height: 16),
          
          // Stats row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                activeCount.build((count) => _buildStatChip(
                  'Active', count, Colors.orange)),
                
                completedCount.build((count) => _buildStatChip(
                  'Completed', count, Colors.green)),
                
                filteredTodos.build((list) => _buildStatChip(
                  'Showing', list.length, Colors.blue)),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Todo list
          Expanded(
            child: filteredTodos.build(
              (todoList) {
                if (todoList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          searchQuery.value.isNotEmpty 
                            ? 'No todos match your search'
                            : filter.value == TodoFilter.completed
                              ? 'No completed todos'
                              : 'No todos yet. Add one above!',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: todoList.length,
                  itemBuilder: (context, index) {
                    final todo = todoList[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Checkbox(
                          value: todo.isCompleted,
                          onChanged: (value) => toggleTodo(todo.id),
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            decoration: todo.isCompleted 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                            color: todo.isCompleted 
                              ? Colors.grey 
                              : Colors.black,
                          ),
                        ),
                        subtitle: todo.description.isNotEmpty 
                          ? Text(todo.description)
                          : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (todo.priority == Priority.high)
                              Icon(Icons.priority_high, color: Colors.red),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => editTodo(context, todo),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => deleteTodo(todo.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              shouldRebuild: (prevList, currentList) {
                // Smart rebuild - only when list actually changes
                if (prevList.length != currentList.length) return true;
                for (int i = 0; i < prevList.length; i++) {
                  if (prevList[i] != currentList[i]) return true;
                }
                return false;
              },
            ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTodoDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildStatChip(String label, int count, Color color) {
    return Chip(
      label: Text('$label: $count'),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }
  
  String _getFilterName(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all: return 'All';
      case TodoFilter.active: return 'Active';
      case TodoFilter.completed: return 'Completed';
    }
  }
  
  void addTodo() {
    if (newTodoText.value.trim().isEmpty) return;
    
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: newTodoText.value.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    
    todos.value = [...todos.value, todo];
    newTodoText.value = '';
  }
  
  void toggleTodo(String id) {
    todos.value = todos.value.map((todo) => 
      todo.id == id ? todo.copyWith(isCompleted: !todo.isCompleted) : todo
    ).toList();
  }
  
  void deleteTodo(String id) {
    todos.value = todos.value.where((todo) => todo.id != id).toList();
  }
  
  void toggleAll() {
    final shouldCompleteAll = !allCompleted.value;
    todos.value = todos.value.map((todo) => 
      todo.copyWith(isCompleted: shouldCompleteAll)
    ).toList();
  }
  
  void clearCompleted() {
    todos.value = todos.value.where((todo) => !todo.isCompleted).toList();
  }
  
  void editTodo(BuildContext context, Todo todo) {
    // Open edit dialog
    showDialog(
      context: context,
      builder: (context) => EditTodoDialog(
        todo: todo,
        onSave: (updatedTodo) {
          todos.value = todos.value.map((t) => 
            t.id == todo.id ? updatedTodo : t
          ).toList();
        },
      ),
    );
  }
  
  void showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddTodoDialog(
        onAdd: (todo) {
          todos.value = [...todos.value, todo];
        },
      ),
    );
  }
}

// Supporting enums and classes
enum TodoFilter { all, active, completed }

enum Priority { low, medium, high }

class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final Priority priority;
  final DateTime createdAt;
  
  Todo({
    required this.id,
    required this.title,
    this.description = '',
    required this.isCompleted,
    this.priority = Priority.medium,
    required this.createdAt,
  });
  
  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    return other is Todo &&
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.isCompleted == isCompleted &&
      other.priority == priority;
  }
  
  @override
  int get hashCode => Object.hash(id, title, description, isCompleted, priority);
}
```

---

## 📋 **Complete Feature Summary**

### **🎯 Two Concepts Only:**
1. **`.watch`** - Create any state: `final anything = value.watch`
2. **`.value`** - Update any state: `anything.value = newValue`

### **🎨 UI Rendering (.build):**
- Single watchables: `watchable.build((value) => Widget)`
- Multi-watchables: `(a, b, c).build((va, vb, vc) => Widget)`
- Conditional rendering, lists, forms, complex UIs

### **⚡ Derived State (.combine):**
- Calculations: `(price, tax).combine((p, t) => p * t)`
- Validations: `(email, password).combine((e, p) => isValid(e, p))`
- Filtering: `(items, query).combine((list, q) => filter(list, q))`

### **🚀 Performance (shouldRebuild):**
- Threshold updates: `shouldRebuild: (prev, curr) => diff(prev, curr) > 0.1`
- Smart comparisons: Only rebuild when specific fields change
- Expensive widget optimization

### **📱 Complete Widgets:**
- Forms with real-time validation
- Shopping carts with calculations
- Todo apps with filtering
- Any complex UI pattern

**Everything uses the same `.watch` + `.value` pattern!** 🎉

---

*This is the complete guide to Watchable UI features. Every pattern shown uses only `.watch` and `.value` - the simplest state management in Flutter.*