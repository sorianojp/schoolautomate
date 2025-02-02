<%@ page language="java" import="utility.*, docTracking.deped.DocReceiveRelease, docTracking.deped.DocumentTracking, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolFromPending = false;//WI.fillTextValue("is_forwarded").equals("1");
	boolean bolFromSearch = false;//WI.fillTextValue("is_forwarded").equals("2");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Document Tracking</title></head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript">
	function FocusField(){
		document.form_.barcode_id.focus();
	}
	
	function SearchBarcode(strKeyCode){
		document.form_.submit();	
	}
	function Search(e) {
		if(e.keyCode == 13) {
			document.form_.submit();
		}
	}
	function ShowDetails(strBarCodeID) {
		
		d = document.getElementById('processing');
		d.style.visibility = 'visible';

		var objCOAInput;
		objCOAInput = document.getElementById("show_details");
		this.InitXmlHttpObject2(objCOAInput, 2, '../../Ajax/ajax-loader_big.gif');//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=20229&barcode_id="+escape(strBarCodeID);

		
		this.processRequest(strURL);
	}
	function CloseWnd() {
		d = document.getElementById('processing');
		d.style.visibility = 'hidden';
	}

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here..
	try{
		dbOP = new DBOperation();
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	Vector vRetResult = null;
	DocReceiveRelease drr = new DocReceiveRelease();
	DocumentTracking dt = new DocumentTracking();
	if(WI.fillTextValue("barcode_id").length() > 0 || WI.fillTextValue("doc_name").length() > 0 || WI.fillTextValue("doc_owner").length() > 0){
		vRetResult = drr.getTransactionInformationOnline(dbOP, request);
		if(vRetResult == null)
			strErrMsg = drr.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" onload="FocusField();">
<div id="processing" style="position:absolute; top:36px; left:251px; width:950px; height:inherit;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% class="thinborderALL" bgcolor="#CCCCCC">
      <tr>
        <td align="right"><a href="javascript:CloseWnd();">Close Window [X]</a></td>
      </tr>
      <tr>
        <td>
		<label id="show_details">&nbsp;</label>
		</td>
      </tr>
</table>

</div>


<form name="form_" action="online_dt_search.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="20" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>::::  ONLINE DOCUMENT TRACKING ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="20" width="3%">&nbsp;</td>
			<td width="87%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="10%" align="right"></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" width="3%">&nbsp;</td>
			<td width="17%">Barcode ID: </td>
			<td width="80%">
				<input type="text" name="barcode_id" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="75" value="<%=WI.fillTextValue("barcode_id")%>" onkeyup="Search(event);">			</td>
		</tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td>Document Name </td>
		  <td>
				<input type="text" name="doc_name" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="75" value="<%=WI.fillTextValue("doc_name")%>" onkeyup="Search(event);">		  </td>
	  </tr>
		<tr>
		  <td height="20">&nbsp;</td>
		  <td>Document Owner </td>
		  <td>
				<input type="text" name="doc_owner" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="75" value="<%=WI.fillTextValue("doc_owner")%>" onkeyup="Search(event);">		  </td>
	  </tr>
		
		<tr>
			<td height="20" colspan="2">&nbsp;</td>
			<td>
				<a href="javascript:SearchBarcode('13');"><input type="button" value="&nbsp; Search &nbsp;" name="search" /></a>
				<font size="1">Click here to search.</font></td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: SEARCH RESULT ::: </strong></div></td>
		</tr>
		<tr>
			<td width="11%" height="20" align="center" class="thinborder"><strong>Barcode </strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Document Name </strong></td>
			<td width="11%" align="center" class="thinborder"><strong>Document Owner </strong></td>
			<td width="11%" align="center" class="thinborder"><strong>Status</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Category</strong></td>
			<td width="11%" align="center" class="thinborder"><strong>Transaction Date </strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 20){
			strTemp = (String)vRetResult.elementAt(i + 14);
			if(strTemp.equals("1")){
				strErrMsg = "Complete/";
				
				if(((String)vRetResult.elementAt(i + 15)).equals("1"))
					strErrMsg += "Released";
				else
					strErrMsg += "Unreleased";
			}
			else
				strErrMsg = "In Process";
		%>

		<tr onclick="ShowDetails('<%=(String)vRetResult.elementAt(i+5)%>');">
			<td height="20" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=strErrMsg%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+17)%></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="20" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>