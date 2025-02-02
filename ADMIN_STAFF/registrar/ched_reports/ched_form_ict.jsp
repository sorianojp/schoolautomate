<%@ page language="java" import="utility.*,java.util.Vector,chedReport.CHEDIctc,chedReport.CHEDInstProfile"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	if (WI.fillTextValue("print_page").equals("1")){
		if (WI.fillTextValue("prepared_by").length()!=0 && WI.fillTextValue("certified_correct").length()!=0 && 
			WI.fillTextValue("prepare_design").length()!=0 && WI.fillTextValue("certify_correct").length()!=0) {
		
%>
	<jsp:forward page="./ched_form_ict_print.jsp" />
	<%  return;
		}else{
		strErrMsg = " Please complete entries for printing ";
		}
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED ICT REPORT</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
.body_font{
	font-size:11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	a {
	text-decoration: none;
	}
</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<script language="JavaScript">
function UpdateICTStaff() {
	var pgLoc = "./ched_form_ict_staff.jsp?sy_from="+document.form_.sy_from.value+
		"&parent_wnd=form_";
	var win=window.open(pgLoc,"EditWindow",'width=600,height=300,top=45,left=345,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage(){
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

function PrepareToEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

function AddNewRecord(){
	document.form_.page_action.value="1";
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.page_action.value="2";
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

function DeleteRecord(){
var vConfirm = confirm(" Confirm Delete Record ");
	if (vConfirm){
		document.form_.page_action.value="0";
		document.form_.print_page.value="0";
		this.SubmitOnce("form_");
	}
}

function CancelEdit() {
	location = "./ched_form_ict.jsp?sy_from=" + document.form_.sy_from.value + "&sy_to=" + document.form_.sy_to.value;
}

function updateFundSource(){
	var loadPg = "./update_fundsource.jsp";	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=750,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function updateHardwareCatg(){
	var loadPg = "./update_hardware_catg.jsp?hardware_type="+(document.form_.hard_type_index.selectedIndex-1);	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=750,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPage(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
</script>

<%
//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-CHED REPORTS-CHED FORM B C","ched_form_ict.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}


Vector vRetResult = null;
Vector vEditResult = null;
CHEDIctc cr = new CHEDIctc();
CHEDInstProfile cip = new CHEDInstProfile();
Vector vInstProfile = null;


String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if (WI.fillTextValue("page_action").equals("0")){
	if (cr.operateOnChedICT(dbOP,request,0) != null){
		strErrMsg = " ICT Data remove successfully";
		strPrepareToEdit = "0";
	}else
		strErrMsg =cr.getErrMsg();	
}else if (WI.fillTextValue("page_action").equals("1")){
	if (cr.operateOnChedICT(dbOP,request,1) != null)
		strErrMsg = " ICT Data saved successfully";
	else
		strErrMsg =cr.getErrMsg();	
}else if (WI.fillTextValue("page_action").equals("2")){
	if (cr.operateOnChedICT(dbOP,request,2) != null){
		strErrMsg = " ICT Data updated successfully";
		strPrepareToEdit = "0";
	}else
		strErrMsg =cr.getErrMsg();	
}

if (strPrepareToEdit.equals("1")){
	vEditResult = cr.operateOnChedICT(dbOP,request,3);
	if (vEditResult == null) {
		strErrMsg = cr.getErrMsg();
	}
}

if (WI.fillTextValue("sy_from").length() == 4){  
	vRetResult = cr.operateOnChedICT(dbOP,request,4);
	vInstProfile = cip.operateOnChedInstProfile(dbOP,request,3);
	
	if (vRetResult == null && cr.getErrMsg() != null) {
		strErrMsg = cr.getErrMsg();
	}
}


String strHardTypeIndex =null;
String[] astrHardTypeIndex = {"WorkStations","Servers","Printers","Accesories"} ;
%>
<body>
<form name="form_" action="./ched_form_ict.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2"><div align="center"><font color="#000000" size="2" face="Arial, Helvetica, sans-serif"><strong>CHED 
          ICT FORM</strong> </font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp; <%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>", "")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="2" bgcolor="#FFFFFF">
    <!--DWLayoutTable-->
    <tr> 
      <td width="186" height="25" class="body_font">&nbsp;Academic Year</td>
      <td width="577"> &nbsp; <% 
	if (vEditResult != null) 
		strTemp = (String)vEditResult.elementAt(1);
	else
		strTemp = WI.fillTextValue("sy_from");
	
	if (strTemp.length()  < 4){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	}
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUP="DisplaySYTo('form_','sy_from','sy_to')">
        to 
        <% 
	if (vEditResult != null) 
		strTemp = (String)vEditResult.elementAt(2);
	else
		strTemp = WI.fillTextValue("sy_to");
	
	if (strTemp.length() < 4 ){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	}
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"> 
        &nbsp;&nbsp; <input type="image" src="../../../images/form_proceed.gif" border="0"> 
      </td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Hardware Type</td>
      <td> &nbsp; <% 		
			if (vEditResult != null) 
				strHardTypeIndex = (String) vEditResult.elementAt(5);
			else
				strHardTypeIndex = WI.fillTextValue("hard_type_index");
	
	  %> <select name="hard_type_index" onChange="ReloadPage()">
          <option value="">Selecte Type of Component</option>
          <% for (int i = 0; i < astrHardTypeIndex.length; ++i) {
				if (strHardTypeIndex.equals(Integer.toString(i))) {%>
          <option value="<%=i%>" selected><%=astrHardTypeIndex[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrHardTypeIndex[i]%></option>
          <%}
		 }%>
        </select></td>
    </tr>
    <%  if (strHardTypeIndex.length() > 0) { %>
    <tr> 
      <td height="25" class="body_font">&nbsp;Hardware Category</td>
      <td>&nbsp; <%
			if (vEditResult != null) 
				strTemp2 = (String) vEditResult.elementAt(6);
			else
				strTemp2 = WI.fillTextValue("hard_catg_index");
	  %> <select name="hard_catg_index">
          <%=dbOP.loadCombo("HARD_CATG_INDEX","HARD_CATG"," from CHED_ICT_HARD_CATG where HARD_TYPE_INDEX= " + strHardTypeIndex
		   						+ " and is_del=0 order by HARD_CATG asc", strTemp2, false)%> </select> 
	&nbsp;&nbsp;
	<a href="javascript:updateHardwareCatg();"> <img src="../../../images/update.gif" border="0"> </a>
	</td>
    </tr>
    <%  if (!strHardTypeIndex.equals("3")) {%>
    <tr> 
      <td height="25" class="body_font">&nbsp;Computer Usage</td>
      <td> &nbsp; <select name="comp_use">
          <option value="0"> Academic Use</option>
          <% 
		  if ( vEditResult != null) 
				strTemp = (String) vEditResult.elementAt(3);
			else
				strTemp = WI.fillTextValue("comp_use");
		  
		  if (strTemp.equals("1")) {%>
          <option value="1" selected> Operations Use</option>
          <%}else{%>
          <option value="1"> Operations Use</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25" class="body_font"> &nbsp;Network Category</td>
      <td> &nbsp; <select name="network_catg" >
          <option value="0">LAN (networked)</option>
          <% 
		  if ( vEditResult != null) 
				strTemp = (String) vEditResult.elementAt(4);
			else
				strTemp = WI.fillTextValue("network_catg");
		  
		  if (strTemp.equals("1")) {%>
          <option value="1" selected> Stand Alone</option>
          <%}else{%>
          <option value="1"> Stand Alone</option>
          <%}%>
        </select> </td>
    </tr>

    <tr> 
      <td height="25" class="body_font">&nbsp;Number of Items (Cloned) </td>
      <%
			if (vEditResult != null) 
				strTemp = WI.getStrValue((String) vEditResult.elementAt(8));
			else
				strTemp = WI.fillTextValue("cloned_items");
	  %>
      <td>&nbsp; <input name="cloned_items" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  	onKeyUP="AllowOnlyInteger('form_','cloned_items')" size="3" maxlength="3"></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Source of Funding</td>
      <td> &nbsp; <%
		if ( vEditResult != null) 
			strTemp = (String) vEditResult.elementAt(9);
		else
			strTemp = WI.fillTextValue("clone_src_fund");
	
	  %> <select name="clone_src_fund">
          <option value="">Select Source</option>
          <%=dbOP.loadCombo("ICT_SRC_FUND_INDEX","ICT_SRC_FUND"," from CHED_ICT_SRC_FUND " + 
							 " where IS_DEL=0 order by ICT_SRC_FUND asc", strTemp, false)%> </select></td>
    </tr>
    <%
		strHardTypeIndex = "Number of Items (Branded)";
	}else{
		strHardTypeIndex = "Number of Items";	
	} %>	
    <tr> 
      <td height="25" class="body_font">&nbsp;<%=strHardTypeIndex%> </td>
      <%
		if ( vEditResult != null) 
			strTemp = WI.getStrValue((String) vEditResult.elementAt(11));
		else
			strTemp = WI.fillTextValue("branded_items");
	
	  %>
      <td>&nbsp; <input name="branded_items" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  	onKeyUP="AllowOnlyInteger('form_','branded_items')" size="3" maxlength="3"></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Source of Funding</td>
      <td>&nbsp; <%
		if ( vEditResult != null) 
			strTemp = (String) vEditResult.elementAt(12);
		else
			strTemp = WI.fillTextValue("branded_src_fund");
	
	  %> <select name="branded_src_fund">
          <option value="">Select Source</option>
          <%=dbOP.loadCombo("ICT_SRC_FUND_INDEX","ICT_SRC_FUND"," from CHED_ICT_SRC_FUND " + 
							 " where IS_DEL=0 order by ICT_SRC_FUND asc", strTemp, false)%> </select>
        <a href="javascript:updateFundSource();"> <img src="../../../images/update.gif" border="0"> </a></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp; <% if (iAccessLevel > 1)  {
		if (!strPrepareToEdit.equals("1")) {
%> <a href="javascript:AddNewRecord()"> <img src="../../../images/save.gif" border="0"></a><font size="1">click 
        to save data </font> <%}else{ %>
		<a href="javascript:EditRecord()"> <img src="../../../images/edit.gif" border="0"></a> 
				<font size="1">click to update data</font> <a href="javascript:CancelEdit()"> 
				<img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
				to cancel edit</font> 		
	<%	if (iAccessLevel == 2) { 
		%>
        <a href="javascript:DeleteRecord()"> <img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
        <font size="1">click to delete data</font> 
        <%} // end delete
		} // end if else iAccessLevel > 1
 } // end iAccessLevel > 1
 %> </td>
    </tr>
    <%} // if hardware type is selected%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>

<% if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DBE8DC"> 
      <td height="25" colspan="17" class="thinborder"><div align="center"><strong>INFORMATION 
          AND COMMUNICATIONS TECHNOLOGY SURVEY</strong><br>
        </div></td>
    </tr>
    <tr> 
      <td colspan="17" valign="middle" class="thinborder"><strong>A. COMPUTER 
        HARDWARE</strong></td>
    </tr>
    <tr> 
      <td width="20%" rowspan="3" valign="middle" class="thinborder"> <p><em>Please 
          count the number of units (institutionwide)</em></p>
        <strong></strong></td>
      <td colspan="8" align="center" valign="middle" class="thinborder"><strong>ACADEMIC 
        USE</strong> </td>
      <td colspan="8" class="thinborder"><div align="center"><strong>OPERATIONS 
          USE</strong></div></td>
    </tr>
    <tr> 
      <td colspan="4" align="center" valign="middle" class="thinborder"><strong></strong> 
        <div align="center"><strong></strong></div>
        <div align="center"><strong>LAN</strong></div></td>
      <td colspan="4" class="thinborder"><div align="center"><strong>STAND ALONE</strong></div></td>
      <td colspan="4" class="thinborder"> <p align="center"><strong>LAN</strong></p></td>
      <td colspan="4" class="thinborder"><div align="center"><strong>STAND ALONE</strong></div></td>
    </tr>
    <tr> 
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>No. 
          of Branded</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">Source 
          of Funding</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">No. 
          of Clone</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">Source 
          of Funding</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">No. 
          of Branded</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">Source 
          of Funding</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">No. 
          of Clone</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">Source 
          of Funding</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">No. 
          of Branded</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">Source 
          of Funding</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">No. 
          of Clone</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">Source 
          of Funding</font></strong></div></td>
      <td class="thinborder"><div align="center"><strong><font size="1">No. of 
          Branded</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">Source 
          of Funding</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">No. 
          of Clone</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">Source 
          of Funding</font></strong></div></td>
    </tr>
    <% 
	int i = 0;

	boolean bolNewCatg = false;
	String strHardCategory = null;
	String strNumClone = "";
	String strCloneSrc = "";
	String strNumBranded = "";
	String strBrandedSrc = "";

	for (i =0; i < vRetResult.size() ;) {
	if ((String)vRetResult.elementAt(i+5) != null) {
		if (Integer.parseInt((String)vRetResult.elementAt(i+5)) >2) 
			break; // break for accessoriess.. show only pc / server / 
	    
%>
    <tr bgcolor="#E5E5E5"> 
      <td height="25" colspan="17" class="thinborder">&nbsp; <strong><%=astrHardTypeIndex[Integer.parseInt((String)vRetResult.elementAt(i+5))]%></strong></td>
    </tr>
    <%
	} // end if classification index not null 
	
	if ((String)vRetResult.elementAt(i+8) == null && 
		 (String)vRetResult.elementAt(i+11) == null)  {// if hardware category has no entry at all
	%>
    <tr> 
      <td height="25" class="thinborder">&nbsp; <%=(String)vRetResult.elementAt(i+7)%></td> 
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>	
	<%
	i+=14;
	}else{%>
    <tr> 
      <td height="25" class="thinborder">&nbsp; <%=(String)vRetResult.elementAt(i+7)%></td>  	

	<% strHardCategory = (String)vRetResult.elementAt(i+6);
	   strNumClone = "";
	   strCloneSrc = "";
	   strNumBranded = "";
	   strBrandedSrc = "";
	
	if (WI.getStrValue((String)vRetResult.elementAt(i+3)).equals("0") && 
		WI.getStrValue((String)vRetResult.elementAt(i+4)).equals("0")){
	   strNumClone = WI.getStrValue((String)vRetResult.elementAt(i+8),
	   								"<a href=\"javascript:PrepareToEdit('" + 
									(String)vRetResult.elementAt(i)+ "')\">","</a>","");
	   strCloneSrc = WI.getStrValue((String)vRetResult.elementAt(i+10));
	   strNumBranded = WI.getStrValue((String)vRetResult.elementAt(i+11),
	   								"<a href=\"javascript:PrepareToEdit('" + 
									(String)vRetResult.elementAt(i)+ "')\">","</a>","");
	   strBrandedSrc = WI.getStrValue((String)vRetResult.elementAt(i+13));	   
	   i+=14;
	}%>

      <td class="thinborder">&nbsp;<%=strNumBranded%></td>
      <td class="thinborder">&nbsp;<%=strBrandedSrc%></td>
      <td class="thinborder">&nbsp;<%=strNumClone%></td>
      <td class="thinborder">&nbsp;<%=strCloneSrc%></td>

	<% strNumClone = "";
	   strCloneSrc = "";
	   strNumBranded = "";
	   strBrandedSrc = "";
	
	if (i < vRetResult.size() && strHardCategory.equals((String)vRetResult.elementAt(i+6)) && 
	    WI.getStrValue((String)vRetResult.elementAt(i+3)).equals("0") && 
		WI.getStrValue((String)vRetResult.elementAt(i+4)).equals("1")){
	   strNumClone = WI.getStrValue((String)vRetResult.elementAt(i+8),
	   								"<a href=\"javascript:PrepareToEdit('" + 
									(String)vRetResult.elementAt(i)+ "')\">","</a>","");
	   strCloneSrc = WI.getStrValue((String)vRetResult.elementAt(i+10));
	   strNumBranded = WI.getStrValue((String)vRetResult.elementAt(i+11),
	   								"<a href=\"javascript:PrepareToEdit('" + 
									(String)vRetResult.elementAt(i)+ "')\">","</a>","");
	   strBrandedSrc = WI.getStrValue((String)vRetResult.elementAt(i+13));	   
	   i+=14;
	}%>
      <td class="thinborder">&nbsp;<%=strNumBranded%></td>
      <td class="thinborder">&nbsp;<%=strBrandedSrc%></td>
      <td class="thinborder">&nbsp;<%=strNumClone%></td>
      <td class="thinborder">&nbsp;<%=strCloneSrc%></td>
	<% strNumClone = "";
	   strCloneSrc = "";
	   strNumBranded = "";
	   strBrandedSrc = "";
	
	if (i < vRetResult.size() && strHardCategory.equals((String)vRetResult.elementAt(i+6)) && 
	    WI.getStrValue((String)vRetResult.elementAt(i+3)).equals("1") && 
		WI.getStrValue((String)vRetResult.elementAt(i+4)).equals("0")){
	   strNumClone = WI.getStrValue((String)vRetResult.elementAt(i+8),
	   								"<a href=\"javascript:PrepareToEdit('" + 
									(String)vRetResult.elementAt(i)+ "')\">","</a>","");
	   strCloneSrc = WI.getStrValue((String)vRetResult.elementAt(i+10));
	   strNumBranded = WI.getStrValue((String)vRetResult.elementAt(i+11),
	   								"<a href=\"javascript:PrepareToEdit('" + 
									(String)vRetResult.elementAt(i)+ "')\">","</a>","");
	   strBrandedSrc = WI.getStrValue((String)vRetResult.elementAt(i+13));	   
	   i+=14;
	}%>
      <td class="thinborder">&nbsp;<%=strNumBranded%></td>
      <td class="thinborder">&nbsp;<%=strBrandedSrc%></td>
      <td class="thinborder">&nbsp;<%=strNumClone%></td>
      <td class="thinborder">&nbsp;<%=strCloneSrc%></td>
	<% strNumClone = "";
	   strCloneSrc = "";
	   strNumBranded = "";
	   strBrandedSrc = "";
	
	if (i < vRetResult.size() && strHardCategory.equals((String)vRetResult.elementAt(i+6)) && 
	    WI.getStrValue((String)vRetResult.elementAt(i+3)).equals("1") && 
		WI.getStrValue((String)vRetResult.elementAt(i+4)).equals("1"))
	{ 
	   strNumClone = WI.getStrValue((String)vRetResult.elementAt(i+8),
	   								"<a href=\"javascript:PrepareToEdit('" + 
									(String)vRetResult.elementAt(i)+ "')\">","</a>","");
	   strCloneSrc = WI.getStrValue((String)vRetResult.elementAt(i+10));
	   strNumBranded = WI.getStrValue((String)vRetResult.elementAt(i+11),
	   								"<a href=\"javascript:PrepareToEdit('" + 
									(String)vRetResult.elementAt(i)+ "')\">","</a>","");
	   strBrandedSrc = WI.getStrValue((String)vRetResult.elementAt(i+13));	   
	   i+=14;
	}%>	  
      <td class="thinborder">&nbsp;<%=strNumBranded%></td>
      <td class="thinborder">&nbsp;<%=strBrandedSrc%></td>
      <td class="thinborder">&nbsp;<%=strNumClone%></td>
      <td class="thinborder">&nbsp;<%=strCloneSrc%></td>
    </tr>
    <% } // end else if hardware category has no entry at all
	  } // end for loop %>
  </table>
  <br>

  <table width="100%" cellpadding="0" cellspacing="0" border="0">
    <tr> 
      <td width="70%">&nbsp; </td>
      <td width="5%">&nbsp;</td>
      <td width="25%"><strong><a href="javascript:UpdateICTStaff()"><img src="../../../images/update.gif" width="60" height="26" align="right" border="0"></a>B. 
        ICT MANPOWER</strong></td>
    </tr>
    <tr>
      <td valign="top"> <% if (i  < vRetResult.size()) {%> 
        <table cellpadding="0" cellspacing="0" border="0" class="thinborder" width="100%">
          <tr> 
            <td width="25%" class="thinborder" height="25"><div align="center"><font size="1"><strong><%=astrHardTypeIndex[Integer.parseInt((String)vRetResult.elementAt(i+5))]%></strong></font></div></td>
            <td width="5%" class="thinborder"> <div align="center"><font size="1"><strong>No.</strong></font></div></td>
            <td width="15%" class="thinborder"> <div align="center"><font size="1"><strong>Source 
                of Funding</strong></font></div></td>
            <td width="25%" class="thinborder"><div align="center"><font size="1"><strong><%=astrHardTypeIndex[Integer.parseInt((String)vRetResult.elementAt(i+5))]%></strong></font></div></td>
            <td width="5%" class="thinborder"> <div align="center"><font size="1"><strong>No.</strong></font></div></td>
            <td width="15%" class="thinborder"> <div align="center"><font size="1"><strong>Source 
                of Funding</strong></font></div></td>
          </tr>
          <% 
 int iMaxSize = 0;
 int iLeftIndex = ((((vRetResult.size() - i)/14)/2) + (((vRetResult.size() - i)/14)%2))*14 + i;
 // ((( / 14)/2)  + ((vRetResult.size() - i) / 14)%2)) *14 + i;
 
 iMaxSize = iLeftIndex;


 for (; i < iMaxSize; i+=14, iLeftIndex+=14){
		 strHardCategory = (String)vRetResult.elementAt(i+7);
	   strNumBranded = WI.getStrValue((String)vRetResult.elementAt(i+11),
	   								"<a href=\"javascript:PrepareToEdit('" + 
									(String)vRetResult.elementAt(i)+ "')\">","</a>","N/A");
		strBrandedSrc = WI.getStrValue((String)vRetResult.elementAt(i+13));
 %>
          <tr> 
            <td class="thinborder">&nbsp;<%=strHardCategory%></td>
            <td class="thinborder">&nbsp;<%=strNumBranded%></td>
            <td class="thinborder">&nbsp;<%=strBrandedSrc%></td>
            <% if (iLeftIndex <vRetResult.size()) {
 		strHardCategory = (String)vRetResult.elementAt(iLeftIndex+7);	
	   strNumBranded = WI.getStrValue((String)vRetResult.elementAt(iLeftIndex+11),
	   								"<a href=\"javascript:PrepareToEdit('" + 
									(String)vRetResult.elementAt(iLeftIndex)+ "')\">","</a>","N/A");
		strBrandedSrc = WI.getStrValue((String)vRetResult.elementAt(iLeftIndex+13));
	}else{
		strHardCategory = "";
		strNumBranded = "";
		strBrandedSrc = "";
	}
 %>
            <td class="thinborder">&nbsp;<%=strHardCategory%></td>
            <td class="thinborder">&nbsp;<%=strNumBranded%></td>
            <td class="thinborder">&nbsp;<%=strBrandedSrc%></td>
          </tr>
          <%}%>
        </table>
        <%} // end if i < vRetResult.size();
 else{%>
        &nbsp <%}%></td>
      <td>&nbsp;</td>
      <td valign="top"><%
if (WI.fillTextValue("sy_from").length() == 4){  
	vRetResult = cr.operateOnChedICTStaff(dbOP,request,4);
	
	if (vRetResult == null && cr.getErrMsg() != null) {
		strErrMsg = cr.getErrMsg();
	}
}

if (vRetResult != null && vRetResult.size() > 0) {


	String[] astrEmpTypeIndex = {"Programmers","System Analyst/Designer","LAN Administrator",
								 "Computer /EDP Operator",  "Database Administrator", 
								 "Instructor / Professor"} ;
%><table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td width="52%" height="25" class="thinborder"><div align="center"><strong>Position</strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>No.</strong></div></td>
    </tr>
    <% 
		String strNumEmp = null;
		int iIndex = 0;
		
		for( i= 0; i <astrEmpTypeIndex.length; i++) {
		if (iIndex  < vRetResult.size() &&  
				i == Integer.parseInt((String)vRetResult.elementAt(iIndex+3))){
			strNumEmp = (String)vRetResult.elementAt(iIndex+4);
			iIndex +=5;
		}else{
			strNumEmp = "";
		}
	%>
    <tr> 
      <td class="thinborder">&nbsp;<%=astrEmpTypeIndex[i]%></td>
      <td class="thinborder"><div align="center">&nbsp;<%=strNumEmp%></div></td>
    </tr>
    <%}%>
  </table>

 <% } // end if vRetResult %></td>
    </tr>
  </table>

  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td class="body_font"> Institution Identifier </td>
      <td height="25"> 
        <%
		if (vInstProfile != null)
			strTemp = WI.getStrValue((String)vInstProfile.elementAt(1));
		else
			strTemp =  WI.fillTextValue("unique_id");
%> <input name="unique_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="16" maxlength="16"> 
      </td>
      <td class="body_font">Region</td>
<%
		if (vInstProfile != null)
			strTemp = WI.getStrValue((String)vInstProfile.elementAt(8));
		else
			strTemp =  WI.fillTextValue("region");
%> 	  
      <td><input name="region" type="text" size="8" maxlength="8"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td class="body_font">Type of Institution </td>
      <td height="25"><select name="type_institution">
          <option value="1"> Private</option>
          <% 

		if (vInstProfile != null){
			strTemp = WI.getStrValue((String)vInstProfile.elementAt(2));
			if (strTemp != null && strTemp.length() > 0) {
				strTemp  = dbOP.mapOneToOther("CHED_OWNERSHIP_TYPE","OWNERSHIP_TYPE_INDEX", strTemp,
												"PRIV_PUBLIC"," and is_del = 0");
				if (strTemp == null)
					strTemp ="";
			}
		 } else
			strTemp =  WI.fillTextValue("type_institution");
	  if (strTemp.equals("0")) {%>
          <option value="0" selected> SUCs</option>
          <%}else{%>
          <option value="0"> SUCs</option>
          <%}%>
        </select></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="14%" class="body_font">Prepared by </td>
      <td width="35%" height="25"><input name="prepared_by" type="text" value="<%=WI.fillTextValue("prepared_by")%>"
	  						 size="32" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="15%" class="body_font">Certified Correct<br></td>
      <td width="36%"><input name="certified_correct" type="text" value="<%=WI.fillTextValue("certified_correct")%>" 
	  				size="32"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td class="body_font">Designation </td>
      <td height="25"><input name="prepare_design" type="text" value="<%=WI.fillTextValue("prepare_design")%>" size="16"  
	  					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td height="25" class="body_font">Designation </td>
      <td height="25"><input name="certify_correct" type="text" value="<%=WI.fillTextValue("certify_correct")%>" size="16"  
	  				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
    </tr>
    <tr> 
      <td height="25" colspan="4"> <div align="center"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print </font></div></td>
    </tr>
  </table>
  <% } // end if vRetResult %>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action" value="">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="print_page" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
