part of 'maintenance.dart';

class RequestFormPage extends StatefulWidget {
  final Maintenance maintenance;

  const RequestFormPage(this.maintenance);

  @override
  _RequestFormPageState createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<RequestFormPage> {
  RequestForm form;
  final formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;

  bool get hasKeyBoard => MediaQuery.of(context).viewInsets.bottom > 100;

  @override
  void initState() {
    widget.maintenance.form
        .then((f) => mounted ? setState(() => form = f) : null);
    super.initState();
  }

  List<Widget> _buildForm() {
    return <Widget>[
      TextFormField(
        maxLines: 4,
        maxLength: 200,
        maxLengthEnforced: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Descriprion',
        ),
        onChanged: (v) => form.description = v,
        validator: (v) => v.isNotEmpty ? null : 'gg',
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: Observer(
              builder: (_) => DropdownButtonFormField(
                hint: Text('Block'),
                items: form.blocks
                    .map((u) => DropdownMenuItem(child: Text(u), value: u))
                    .toList(),
                value: form.block,
                onChanged: (v) => form.block = v,
                validator: (v) => v != null && form.blocks.contains(v)
                    ? null
                    : 'Format Error',
              ),
            ),
          ),
          VerticalDivider(),
          Expanded(
            child: Observer(
              builder: (_) => DropdownButtonFormField(
                hint: Text('Wing'),
                items: form.wings
                    .map((u) => DropdownMenuItem(child: Text(u), value: u))
                    .toList(),
                value: form.wing,
                onChanged: (v) => form.wing = v,
                validator: (v) =>
                    v != null && form.wings.contains(v) ? null : 'Format Error',
              ),
            ),
          ),
          VerticalDivider(),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(hintText: 'Room'),
              onChanged: (v) => form.room = v,
              validator: (v) =>
                  v != null && v.isNotEmpty ? null : 'Format Error',
            ),
          )
        ],
      ),
      AnimatedPadding(
        padding: EdgeInsets.only(right: hasKeyBoard ? 0 : 140),
        duration: const Duration(milliseconds: 100),
        child: Observer(
          builder: (_) => DropdownButtonFormField(
            decoration: InputDecoration(labelText: 'Room Usage'),
            items: form.usages
                .map((u) => DropdownMenuItem(child: Text(u), value: u))
                .toList(),
            value: form.usage,
            onChanged: (v) => form.usage = v,
            validator: (v) =>
                v != null && form.usages.contains(v) ? null : 'Format Error',
          ),
        ),
      ),
      AnimatedPadding(
        padding: EdgeInsets.only(right: hasKeyBoard ? 0 : 140),
        duration: const Duration(milliseconds: 100),
        child: Observer(
          builder: (_) => DropdownButtonFormField(
            decoration: InputDecoration(labelText: 'Category'),
            items: form.categories
                .map((u) => DropdownMenuItem(child: Text(u), value: u))
                .toList(),
            value: form.category,
            onChanged: (v) => form.category = v,
            validator: (v) => v != null && form.categories.contains(v)
                ? null
                : 'Format Error',
          ),
        ),
      ),
      AnimatedPadding(
        padding: EdgeInsets.only(right: hasKeyBoard ? 0 : 140),
        duration: const Duration(milliseconds: 100),
        child: TextFormField(
          initialValue: form.phoneNumber,
          decoration: InputDecoration(labelText: 'Contact Number'),
          keyboardType: TextInputType.phone,
          onChanged: (v) => form.phoneNumber = v,
          validator: (v) => v != null && v.isNotEmpty ? null : 'Format Error',
        ),
      ),
      AnimatedPadding(
        padding: EdgeInsets.only(right: hasKeyBoard ? 0 : 140),
        duration: const Duration(milliseconds: 100),
        child: Observer(
          builder: (context) => CheckboxListTile(
            title: Text('Recurring Problem'),
            value: form.recurringProblem,
            onChanged: (v) => form.recurringProblem = v,
          ),
        ),
      ),
      Divider(height: 10, color: Colors.transparent),
      Row(
        mainAxisAlignment: hasKeyBoard
            ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.start,
        children: <Widget>[
          if (!hasKeyBoard) VerticalDivider(width: 30),
          FloatingActionButton(
            heroTag: 'x',
            backgroundColor: Theme.of(context).canvasColor,
            child: Icon(
              Icons.close,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          if (!hasKeyBoard) VerticalDivider(width: 25),
          Observer(
            builder: (context) => FloatingActionButton(
              heroTag: 'camera',
              backgroundColor: Theme.of(context).canvasColor,
              tooltip: 'Add Photo',
              child: Icon(
                form.file == null ? Icons.camera : Icons.delete_outline,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () async {
                if (form.file != null) {
                  form.file = null;
                  return;
                }
                var imageFile =
                    await ImagePicker.pickImage(source: ImageSource.camera);
                form.file = imageFile;
              },
            ),
          ),
          if (!hasKeyBoard) VerticalDivider(width: 25),
          FloatingActionButton(
            disabledElevation: 0,
            child: Icon(Icons.check),
            onPressed: () async {
              if (!formKey.currentState.validate() || _isSubmitting) return;
              _isSubmitting = true;
              await widget.maintenance.sendForm(form);
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Text(
          'Request Maintenance',
          style: Theme.of(context).textTheme.title,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          if (!hasKeyBoard)
            Positioned(
              right: 5,
              bottom: 20,
              child: SvgPicture.asset('res/campus/maintenance.svg', width: 125),
            ),
          if (form == null) Center(child: CircularProgressIndicator()),
          if (form != null)
            Form(
              key: formKey,
              child: ListView(
                padding: EdgeInsets.all(15),
                children: _buildForm(),
              ),
            ),
        ],
      ),
    );
  }
}