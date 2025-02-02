<%@ page language="java" import="utility.*,java.util.Vector,inventory.InventoryDonors" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Donors</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(){
  document.form_.donot_call_close_wnd.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function PageAction(strAction,strIndex,strDonorName){
	document.form_.donot_call_close_wnd.value = "1";
	if(strAction == 0){
		var vProceed = confirm('Delete '+strDonorName+' ?');
		if(vProceed){
			document.form_.print_pg.value = "";
			document.form_.pageAction.value = strAction;
			document.form_.strIndex.value = strIndex;
			this.SubmitOnce('form_');
		}
	}
	else{
		document.form_.print_pg.value = "";
		document.form_.pageAction.value = strAction;
		document.form_.strIndex.value = strIndex;
		this.SubmitOnce('form_');
	}
}
function CancelClicked(){
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.print_pg.value = "1";
	this.SubmitOnce('form_');
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	document.form_.donot_call_close_wnd.value = "1";
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadMain(){
<% if (WI.fillTextValue("opner_form_field").length() != 0){%>
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>[window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>.selectedIndex].value = 
		document.form_.opner_form_field_value.value;
<% }%>

	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();

		window.opener.focus();
	}
}
function FocusName(){
	document.form_.donor_name.focus();
}
</script>
<%
	if(WI.fillTextValue("print_pg").equals("1")){%>
		<jsp:forward page="donors_print.jsp"/>
	<%return;}		
	
//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-DONORS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-DONORS","donors.jsp");
	
	InventoryDonors invDonor = new InventoryDonors();
	Vector vRetResult = new Vector();
	Vector vRetDonors = new Vector();
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	int iSearchResult = 0;
	int i = 0;

	if(WI.fillTextValue("pageAction").length() > 0){
		vRetResult = invDonor.operateOnDonorInfo(dbOP,request,
					 	Integer.parseInt(WI.getStrValue(WI.fillTextValue("pageAction"),"4")));	    

		if(vRetResult == null)
			strErrMsg = invDonor.getErrMsg();
		else if(vRetResult != null && !((WI.fillTextValue("pageAction").equals("3") || WI.fillTextValue("pageAction").equals("5"))))
			strErrMsg = "Operation Successful.";			
	}	
	
	vRetDonors = invDonor.operateOnDonorInfo(dbOP,request,4);
	if(vRetDonors != null){
		iSearchResult = invDonor.getSearchCount();
	}
%>
<body bgcolor="#D2AE72" onUnload="ReloadMain();" onLoad="FocusName();">
<form name="form_" method="post" action="./donors.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          INVENTORY - DONOR : PROFILES PAGE ::::</strong></font></div></td>
    </tr>
    <tr valign="top" bgcolor="#FFFFFF"> 
      <td height="31" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="3%" height="15">&nbsp;</td>
      <td width="17%" height="15">Donor Name:</td>
      <td width="160%" height="15" colspan="2"> 
			<%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = (String)vRetResult.elementAt(2);
	    else if(WI.fillTextValue("donor_name").length() > 0)
	  		strTemp = WI.fillTextValue("donor_name");
	    else
	  		strTemp = "";
	  %> <input name="donor_name" type="text" value="<%=WI.getStrValue(strTemp,"")%>" size="45" maxlength="128" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur='style.backgroundColor="white"'></td>
    </tr>
		<!--
    <tr bgcolor="#FFFFFF">
      <td height="15">&nbsp;</td>
      <td height="15">Donor Type:</td>
      <td height="15" colspan="2"><select name="donor_type">
          <option value="">Select Type</option>
          <%strTemp = WI.fillTextValue("type_index");%>
          <%=dbOP.loadCombo("donor_type_index","donor_type"," from inv_preload_donor_type order by donor_type", strTemp, false)%> 
        </select>
        <a href='javascript:viewList("inv_preload_donor_type","DONOR_TYPE_INDEX","DONOR_TYPE","DONOR TYPE",
		"INV_DONOR_LIST","DONOR_TYPE_INDEX","","","type_index")'></a></td>
    </tr>
		-->
    <tr bgcolor="#FFFFFF"> 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="1%" height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong><u>ADDRESS</u></strong></td>
      <td width="80%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td width="2%" height="25">&nbsp;</td>
      <td width="17%">Address</td>
      <td height="25"> 
			<%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = (String)vRetResult.elementAt(3);
	    else if(WI.fillTextValue("address").length() > 0)
	  		strTemp = WI.fillTextValue("address");
	    else
	  		strTemp = "";
	  %> <input name="address" value="<%=WI.getStrValue(strTemp,"")%>" type="text" size="32" 
		maxlength="128" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="1%" height="21">&nbsp;</td>
      <td height="21" colspan="2"><strong><u>CONTACT INFO</u></strong></td>
      <td height="21" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td width="2%" height="25">&nbsp;</td>
      <td width="17%">Contact Number<strong></strong></td>
      <td width="36%" height="25"> <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = (String)vRetResult.elementAt(4);
	    else if(WI.fillTextValue("contact_no").length() > 0)
	  		strTemp = WI.fillTextValue("contact_no");	  
	    else
	  		strTemp = "";
	  %> <input name="contact_no" value="<%=WI.getStrValue(strTemp,"")%>" onKeyUp="AllowOnlyIntegerExtn('form_','contact_no','-')" type="text" size="32" maxlength="32" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
      <td width="44%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Contact Person</td>
      <td height="25" colspan="2"> <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = (String)vRetResult.elementAt(5);
	  	else if(WI.fillTextValue("con_person").length() > 0)
	  		strTemp = WI.fillTextValue("con_person");
	  	else
	  		strTemp = "";
	  %> <input name="con_person" value="<%=WI.getStrValue(strTemp,"")%>" type="text" size="32" maxlength="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="31">&nbsp;</td>
      <td height="31">&nbsp;</td>
      <td height="31">&nbsp;</td>
      <td height="31" colspan="2"><font size="1"> 
        <%if(WI.fillTextValue("pageAction").equals("3") || (WI.fillTextValue("pageAction").equals("2") && vRetResult == null)){%>
        <a href="javascript:PageAction(2,'<%=WI.fillTextValue("strIndex")%>','')"> 
        <img src="../../../images/edit.gif" border="0"></a>click to edit event&nbsp; 
        <%}else{%>
        <a href="javascript:PageAction(1,'','');"> <img src="../../../images/save.gif" border="0"></a>click 
        to save entries&nbsp; 
        <%}%>
        <a href="javascript:CancelClicked();"> <img src="../../../images/cancel.gif" border="0"></a>click 
      to cancel/clear entries </font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" dwcopytype="CopyTableRow">
  <%if(vRetDonors != null){
  		if(vRetDonors.size() > 1){%>
    <tr> 
      <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF DONORS</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="6" class="thinborder"><div align="right">Number of Donors Per 
          Page:
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
				for(i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
        <a href="javascript:PrintPage();"> <img src="../../../images/print.gif" border="0"></a><font size="1">click to print list</font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><strong>TOTAL DONOR(S) : 
        <%=vRetDonors.size()/6%></strong></td>
      <td height="25" colspan="2" class="thinborder"><span class="thinborderBOTTOM">Page
      <%
		int iPageCount = iSearchResult/invDonor.defSearchSize;
		if(iSearchResult % invDonor.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%>
      <select name="jumpto" onChange="ReloadPage();" style="font-size:11px">
        <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
        <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
        <%}else{%>
        <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
        <%	}
			}// end page printing
			%>
      </select>
      <%} else {%>
&nbsp;
<%} //if no pages %>
      </span></td>
    </tr>
    <tr> 
      <td width="24%" height="25" align="center" class="thinborder"><strong>DONOR 
        NAME</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>TYPE</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>CONTACT NOS.</strong></td>
      <td width="27%" align="center" class="thinborder"><strong>CONTACT PERSON</strong></td>
      <td width="10%" colspan="2" align="center" class="thinborder"><strong>OPTIONS</strong></td>
    </tr>
    <%for(i= 0;i < vRetDonors.size();i+=6){%>
    <tr> 
      <td height="29" class="thinborder">&nbsp;<%=(String)vRetDonors.elementAt(i+2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetDonors.elementAt(i+1)%></td>
      <%
				strTemp = (String)vRetDonors.elementAt(i+4);			
			%>
			<td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
				strTemp = (String)vRetDonors.elementAt(i+5);			
			%>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td width="10%" class="thinborder"><div align="center"><a href="javascript:PageAction(3,'<%=(String)vRetDonors.elementAt(i)%>','');"><img src="../../../images/edit.gif" border="0"></a></div></td>
      <td width="5%" class="thinborder"><div align="center"><a href="javascript:PageAction(0,'<%=(String)vRetDonors.elementAt(i)%>','<%=(String)vRetDonors.elementAt(i+2)%>');"><img src="../../../images/delete.gif" border="0"></a></div></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
	<%}}%>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="strIndex" value="<%=WI.fillTextValue("strIndex")%>">
  <input type="hidden" name="print_pg" value="">
	<input type="hidden" name="donor_type" value="<%=WI.fillTextValue("donor_type")%>">
<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
  
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>
