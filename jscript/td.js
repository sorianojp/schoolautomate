/***********************************EXAMPLE****************************
<a href="javascript:hideLayer('row_1');">hide row 1</a><br>
<a href="javascript:showLayer('row_1');">show row 1</a><br>
<a href="javascript:hideLayer('row_2');">hide row 2</a><br>
<a href="javascript:showLayer('row_2');">show row 2</a><br>
<a href="javascript:hideLayer('row_3');">hide row 3</a><br>
<a href="javascript:showLayer('row_3');">show row 3</a><br>
<a href="javascript:hideLayer('row_4');">hide row 4</a><br>
<a href="javascript:showLayer('row_4');">show row 4</a><br>
<a href="javascript:hideLayer('row_5');">hide row 5</a><br>
<a href="javascript:showLayer('row_5');">show row 5</a><br>
<table border="1" width="300">
<tr id="row_1"><td>Row 1</td></tr> <tr id="row_2"><td>Row 2</td></tr>
<tr id="row_3"><td>Row 3</td></tr> <tr id="row_4"><td>Row 4</td></tr>
<tr id="row_5"><td>Row 5</td></tr> </table>
*/

//Gets a handle to all style parts of an object using ID to access it
function getObj(name, nest)
{
	if (document.getElementById) {
		//if(!document.getElementById(name))
		//	return;
		return document.getElementById(name).style;
	}
	else if (document.all) {
		//if(!document.all[name])
		//	return;
		return document.all[name].style;
	}
	else if (document.layers) {
		if (nest != '') {
			return eval('document.'+nest+'.document.layers["'+name+'"]');
		}
	}
	else
	{
		return document.layers[name];
	}
} //Hide/show layers

function showLayer(layerName, nest)
{
	var x = getObj(layerName, nest);
	//if(!x)
	//	return;
	x.visibility = "visible";
}
function hideLayer(layerName, nest)
{
	var x = getObj(layerName, nest);
	//if(!x)
	//	return;
	x.visibility = "hidden";
}
