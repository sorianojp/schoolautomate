<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<script src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="javascript">

function CancelOperation(){
	document.form_.preparedToEdit.value = "0";
	document.form_.page_action.value = "";
}

function OpenSearch() {
	var pgLoc = "../search/search_simple.jsp?opner_info=form_.accession_no&opner_info2=form_.reload_main&opner_info2_val=1";
	var win=window.open(pgLoc,"PrintWindow",'width=950,height=650,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateSupplier() {
	var pgLoc = "./supplier.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=950,height=650,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../ADMIN_STAFF/HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"viewList",'dependent=yes,width=700,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateMaterialType(){
	var pgLoc = "../cataloging/lib_collection/add_material_type.jsp?setup_dtls_index="+document.form_.setup_ref.value+"&sub_index="+document.form_.sub_index.value;	
	var win=window.open(pgLoc,"UpdateSubCourseKeyword",'width=800,height=400,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateSubCourseKeyword(){
	var pgLoc = "./subject_keywords.jsp?setup_dtls_index="+document.form_.setup_ref.value+"&sub_index="+document.form_.sub_index.value;	
	var win=window.open(pgLoc,"UpdateSubCourseKeyword",'width=600,height=400,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<%@ page language="java" import="utility.*,lms.LmsAcquision,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null; String strTemp = null;
	String strUserIndex  = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth != null)
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Acquisition".toUpperCase()),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}

//end of authenticaion code.

	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");

boolean bolShowCreateButton = true;
String strInfoIndex = WI.fillTextValue("info_index");
if(WI.fillTextValue("setup_ref").length() > 0)
	strInfoIndex = WI.fillTextValue("setup_ref");

if(strInfoIndex.length() > 0){
	strTemp = "select setup_index from LMS_ACQ_SETUP_DTLS where is_selected = 1 and setup_index = "+strInfoIndex;
	if(dbOP.getResultOfAQuery(strTemp, 0) != null)
		bolShowCreateButton = false;
}

LmsAcquision lmsAcq = new LmsAcquision();
Vector vRetResult   = null; 
Vector vSelMainInfo = null; 
Vector vBookInfo 	= null; 
Vector vEditInfo 	= null;

String strSetupRef = WI.fillTextValue("setup_ref");
if(strSetupRef.length() == 0) 
	strErrMsg = "Set up main reference index is missing. Please close this window and try again.";
else {
	vSelMainInfo = lmsAcq.operateOnBookSelectionMain(dbOP, request, 3);					
	if(vSelMainInfo == null)
		strErrMsg = lmsAcq.getErrMsg();
}


strTemp = WI.fillTextValue("accession_no");

if(strTemp.length() > 0) {
	vBookInfo = lmsAcq.operateOnBookSelectionDtls(dbOP, request, 5);
	
	if(vBookInfo == null)
		strErrMsg = lmsAcq.getErrMsg();
	//System.out.println(strErrMsg);
}


if(vSelMainInfo != null) {
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(lmsAcq.operateOnBookSelectionDtls(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = lmsAcq.getErrMsg();
		else {
			strErrMsg = "Request processed successfully.";
			strPreparedToEdit = "0";
		}
	}
	vRetResult = lmsAcq.operateOnBookSelectionDtls(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = lmsAcq.getErrMsg();



	if(strPreparedToEdit.equals("1")) {		
		vEditInfo = lmsAcq.operateOnBookSelectionDtls(dbOP, request, 3);
		if(vEditInfo == null) {
			strErrMsg = lmsAcq.getErrMsg();
			strPreparedToEdit = "0";
		}
	}
}
%>
<body bgcolor="#FAD3E0">
<form action="./selection_dtls.jsp?setup_ref=<%=strSetupRef%>" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#0D3371">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>:::: ACQUISITION - BOOK SELECTION  PAGE ::::</strong></font></div></td>
    </tr>
</table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td colspan="3" style="font-size:13px; font-weight:bold; color:#FF0000"> &nbsp;&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
      </tr>
<%if(vSelMainInfo == null){
	dbOP.cleanUP();
	return;
}
vSelMainInfo.remove(6);
strTemp = (String)vSelMainInfo.remove(5);%>
      <tr>
        <td width="10%" height="24">School Years : </td>
        <td width="10%"><b><%=strTemp%> - <%=Integer.parseInt(strTemp) + 1%></b></td>
        <td width="80%">Reference Number : <b><%=vSelMainInfo.remove(1)%></b></td>
      </tr>
      <tr>
<%
vSelMainInfo.remove(1);vSelMainInfo.remove(1);
%>
        <td height="24">Course</td>
        <td colspan="2"><b><%=vSelMainInfo.remove(1)%></b></td>
      </tr>
	</table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td height="12" colspan="9"><hr size="1"></td>
      </tr>
      <tr>
        <td width="2%" height="12">&nbsp;</td>
        <td height="12" colspan="8"><font size="2" color="#666633"><b>Load from existing Book (Enter Accession No) :</b></font>
		 <input name="accession_no" type="text" size="24" maxlength="32" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch();"><img src="../images/search.gif" border="0"></a>
		
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="submit" name="_1" value="Reload Page" onClick="document.form_.page_action.value=''">		</td>
      </tr>
      <tr>
        <td height="12">&nbsp;</td>
        <td height="12" width="12%"><font size="2" color="#666633"><b>Book Title  :</b></font></td>
		<td colspan="8">
<%
if(vBookInfo != null) 
	strTemp = (String)vBookInfo.elementAt(3);
else if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("book_title");
%>
		 <input name="book_title" type="text" size="64" maxlength="128" value="<%=strTemp%>" 
		 	class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
      </tr>
      <tr>
        <td height="24">&nbsp;</td>
        <td height="12" valign="middle"><font size="2" color="#666633"><b>Author  :</b></font></td>
		<%
			if(vBookInfo != null) 
				strTemp = (String)vBookInfo.elementAt(1);
			else if(vEditInfo != null && vEditInfo.size() > 0) 
				strTemp = (String)vEditInfo.elementAt(1);
			else	
				strTemp = WI.fillTextValue("author_name");
			%>
		<td width="15%"><input name="author_name" type="text" size="24" 
		 	maxlength="64" value="<%=WI.getStrValue(strTemp)%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
        <td width="" height="12" valign="middle" align="right"><font size="2" color="#666633"><b>Edition  : &nbsp;</b></font></td>
		
<%
if(vBookInfo != null) 
	strTemp = (String)vBookInfo.elementAt(2);
else if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("edition");
%>
		 
		<td width="17%">&nbsp;<input name="edition" type="text" size="24" 
			maxlength="32" value="<%=WI.getStrValue(strTemp)%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
        <td width="15%" valign="middle" align="right"><font size="2" color="#666633"><b>Place of Publication  : &nbsp;</b></font></td>
		<%
			if(vBookInfo != null) 
				strTemp = (String)vBookInfo.elementAt(4);
			else if(vEditInfo != null && vEditInfo.size() > 0) 
				strTemp = (String)vEditInfo.elementAt(3);
			else	
				strTemp = WI.fillTextValue("publisher");
			%>
		 
		<td>&nbsp;<input name="publisher" type="text" size="32" 
			maxlength="128" value="<%=WI.getStrValue(strTemp)%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
        
      </tr>
	  
	  
	  
	   <tr>
        <td height="24">&nbsp;</td>
        <td height="12" valign="middle"><font size="2" color="#666633"><b>Copyright Year  :</b></font></td>
		<%
			if(vBookInfo != null) 
				strTemp = (String)vBookInfo.elementAt(5);
			else if(vEditInfo != null && vEditInfo.size() > 0) 
				strTemp = (String)vEditInfo.elementAt(13);
			else	
				strTemp = WI.fillTextValue("copyright_year");
			%>
		<td width="">			
		<input name="copyright_year" type="text" size="10" 
		 	maxlength="64" value="<%=WI.getStrValue(strTemp)%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
        <td width="10%" height="12" valign="middle" align="right"><font size="2" color="#666633"><b>Editor  : &nbsp;</b></font></td>
		
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(14);
else	
	strTemp = WI.fillTextValue("editor");
%>
		 
		<td width="15%">&nbsp;<input name="editor" type="text" size="24" 
			maxlength="32" value="<%=WI.getStrValue(strTemp)%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
        <td width="15%" valign="middle" align="right"><font size="2" color="#666633"><b>Date Purchased  : &nbsp;</b></font></td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0) 
				strTemp = (String)vEditInfo.elementAt(15);
			else	
				strTemp = WI.fillTextValue("date_purchased");
			%>
		 
		<td>&nbsp;<input name="date_purchased" type="text" size="10" readonly="yes"
			maxlength="128" value="<%=WI.getStrValue(strTemp)%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<a href="javascript:show_calendar('form_.date_purchased');" title="Click to select date" onMouseOver="window.status='Select date';return true;" 
			onMouseOut="window.status='';return true;"><img src="../images/calendar_new.gif" border="0"></a>	
		</td>
        
      </tr>
	  
	  
	  
	  <tr>
        <td height="">&nbsp;</td>
        <td height="" valign="middle"><font size="2" color="#666633"><b>Publisher  :</b></font></td>		
			
			<%	if(vBookInfo != null) 
					strTemp = (String)vBookInfo.elementAt(6);
				else if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(16); 
				else
					strTemp = request.getParameter("PUBLISHER_INDEX");			
			%>	
		<td width="" colspan="5" valign="">
			<select name="PUBLISHER_INDEX" style="font-family:Verdana, Arial, Helvetica, sans-serif; width:500px; font-size: 10;">
          		<%=dbOP.loadCombo("PUBLISHER_INDEX","PUBLISHER"," from LMS_LC_PUBLISHER order by PUBLISHER asc",strTemp, false)%> 
			</select>
			&nbsp; &nbsp; &nbsp; 
			<font size="1">			
			<a href='javascript:viewList("LMS_LC_PUBLISHER","PUBLISHER_INDEX","PUBLISHER","PUBLISHER","LMS_LC_MAIN","PUBLISHER_INDEX"," and is_valid = 1 ","","PUBLISHER_INDEX");'>
				<img src="../images/update.gif" border="0" align="absmiddle" width="60" height="25"></a></font>
			</td>
        
      </tr>
	  
	  
	  
	  
	  
	  
	  
      <tr>
        <td height="24">&nbsp;</td>
        <td height="12" colspan="3"><font size="2" color="#666633"><b>Current no. of copies   : </b></font>
<%
if(vBookInfo != null) 
	strTemp = (String)vBookInfo.elementAt(6);
else if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("copies");
%>
		 <input name="copies" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		 	onBlur="AllowOnlyInteger('form_','copies');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','copies');">		</td>
        <td height="12" colspan="3"><font size="2" color="#666633"><b>Purchase Unit Price: </b></font>
<%
if(vBookInfo != null) 
	strTemp = (String)vBookInfo.elementAt(5);
else if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("last_pur_price");

if(strTemp != null && strTemp.length() > 0)
	strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp, true), ",","");
%>
		 <input name="last_pur_price" type="text" size="7" maxlength="12" value="<%=WI.getStrValue(strTemp)%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		 	onBlur="AllowOnlyIntegerExtn('form_','last_pur_price','.');style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('form_','last_pur_price','.');">        </td>
        
      </tr>
	  
</table>
	  
<table width="100%" border="0" cellpadding="0" cellspacing="0">	
	<tr><td height="10" colspan="9"><hr size="1"></td></tr>
      
      <tr>
        <td height="24">&nbsp;</td>
        <td><font size="2" color="#666633"><b>Material Type</b></font></td>
		<td colspan="3">
		<%
		strTemp = WI.fillTextValue("MATERIAL_TYPE_INDEX");
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(17);
		%>
		<select name="MATERIAL_TYPE_INDEX" 
	  			style="font-family:Verdana, Arial, Helvetica, sans-serif; width:500px; font-size: 10;">
          <%=dbOP.loadCombo("MATERIAL_TYPE_INDEX","MATERIAL_TYPE"," from LMS_MAT_TYPE order by  MATERIAL_TYPE_INDEX asc",strTemp, false)%> 
        </select>
		<a href='javascript:UpdateMaterialType();'><img src="../images/update.gif" border="0" align="absmiddle" height="25" width="60"></a>
		</td>
      </tr>
	  <tr>
        <td height="24">&nbsp;</td>
        <td><font size="2" color="#666633"><b>Source</b></font></td>
		<td colspan="3">
		<%
		strTemp = WI.fillTextValue("source");		
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(18);		
		%>
		<select name="source" 
	  			style="font-family:Verdana, Arial, Helvetica, sans-serif; width:500px; font-size: 10;">
          <%=dbOP.loadCombo("SOURCE_INDEX","SOURCE_NAME"," from LMS_ACQ_SOURCE order by  SOURCE_NAME asc",strTemp, false)%> 
        </select>
		
		<a href='javascript:viewList("LMS_ACQ_SOURCE","SOURCE_INDEX","SOURCE_NAME","SOURCE","LMS_ACQ_SETUP_DTLS","SOURCE_INDEX"," ","","source");'><img src="../images/update.gif" border="0" align="absmiddle" height="25" width="60"></a>
		</td>
      </tr>
	  
	  <tr>
        <td height="24">&nbsp;</td>
        <td><font size="2" color="#666633"><b>Keywords</b></font></td>		
		<td colspan="3">
			<%
			strTemp = WI.fillTextValue("keywords");
			if(vEditInfo != null && vEditInfo.size() > 0) 
				strTemp = (String)vEditInfo.elementAt(19);
			%>
			<input name="keywords" type="text" size="60" maxlength="256" value="<%=WI.getStrValue(strTemp)%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		 	onBlur="style.backgroundColor='white'">
		</td>
	  </tr>
	  <tr><td colspan="5" height="5"></td></tr>
	  <tr> 
      <td>&nbsp;</td>
      <td colspan="4" valign="bottom"><font color="#666633"><b>Subject Course : </b></font><font size="1"> 
        <input type="text" name="scroll_sub" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'form_');">
        (enter subject code to scroll the list)</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="4" valign="bottom">
	  <select name="sub_index" title="SELECT A  SUBJECT"
	  	style="font-size:11px; width:500px; font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;">         
          <option value=""></option>
		  <%=dbOP.loadCombo("sub_index","sub_code +'&nbsp;&nbsp;&nbsp;('+sub_name+')' as s_code"," from subject where is_del=0 ",WI.fillTextValue("sub_index"), false)%> 
		</select>
		
		<a href='javascript:UpdateSubCourseKeyword();'><img src="../images/update.gif" border="0" align="absmiddle" height="25" width="60"></a>
		</td>
    </tr>
	  
	  
	  
	  <tr>
        <td height="24">&nbsp;</td>
        <td><font size="2" color="#666633"><b>Requested by</b></font></td>		
		<td colspan="3">
			<%
			strTemp = WI.fillTextValue("requested_by");
			if(vEditInfo != null && vEditInfo.size() > 0) 
				strTemp = (String)vEditInfo.elementAt(20);
			%>
			<input name="requested_by" type="text" size="60" maxlength="256" value="<%=WI.getStrValue(strTemp)%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		 	onBlur="style.backgroundColor='white'">
		</td>
	  </tr>
	  
	  
	  
	  <tr>
        <td width="2%" height="25">&nbsp;</td>
        <td height="25" width="17%"><font size="2" color="#666633"><b>Quantity to order : </b></font></td>
		<td width="15%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("qty");
%>
		 <input name="qty" type="text" size="4" maxlength="5" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		 	onBlur="AllowOnlyInteger('form_','qty');style.backgroundColor='white'" onKeyUP="AllowOnlyInteger('form_','qty');">        </td>
        <td height="25" width="17%"><font size="2" color="#666633"><b>Supplier:</b></font></td>
		<td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("supplier");
%>
		<select name="supplier">
          <%=dbOP.loadCombo("supplier_index","supplier_name"," from lms_acq_supplier where is_valid = 1 and is_active = 1 order by supplier_name",strTemp, false)%> 
		</select>
              <a href="javascript:UpdateSupplier();"><img src="../images/update.gif" border="0" align="absmiddle" height="25" width="60"></a></td>
        
      </tr>
      <tr>
        <td height="25">&nbsp;</td>
        <td height="25"><font size="2" color="#666633"><b>Unit Price:</b></font></td>
		<td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(9);
else	
	strTemp = WI.fillTextValue("unit_price");

if(strTemp != null && strTemp.length() > 0)
	strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp, true), ",","");
%>
		<font size="2" color="#666633"><b>
		 <input name="unit_price" type="text" size="7" maxlength="12" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		 onBlur="AllowOnlyIntegerExtn('form_','unit_price','.');style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('form_','unit_price','.');">
        </b></font></td>
        <td height="24" valign="bottom" colspan="3">
<%if(!strPreparedToEdit.equals("1") && bolShowCreateButton){%>
		<input type="submit" name="_1" value="Create Details" onClick="document.form_.page_action.value='1';">
<%}else if ( vEditInfo != null && vEditInfo.size() > 0 && strPreparedToEdit.equals("1") ){//add.. or edit.. %>
		<input type="submit" name="_1" value="Edit Information" onClick="document.form_.page_action.value='2';document.form_.info_index.value='<%=vEditInfo.elementAt(0)%>'">
		&nbsp;&nbsp;&nbsp;
		<input type="submit" name="_1" value="Cancel" onClick="CancelOperation();">
<%}%>		
		
		</td>
        
      </tr>
	  
    </table>
	
	
	
<%if(vRetResult != null && vRetResult.size() > 0) {%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr bgcolor="#9DB6F4">
    <td height="25" colspan="10" align="center" class="thinborder"><font color="#FFFFFF" ><strong>:::: LIST OF BOOKS SELECTION FOR ACQUISITION ::::</strong></font></td>
    </tr>
  <tr bgcolor="#C6D3F4" align="center" style="font-weight:bold">
    <td width="6%" class="thinborder">Count</td>
    <td width="6%" height="25" class="thinborder">Qty</td>
    <td width="7%" class="thinborder">Author</td>
    <td width="22%" class="thinborder">Title</td>
    <td width="10%" class="thinborder">Edition</td>
    <td width="17%" class="thinborder">Supplier</td>
    <td width="8%" class="thinborder">Unit Price</td>
    <td width="14%" class="thinborder">Total Amount</td>
    <td width="5%" class="thinborder">Edit</td>
    <td width="5%" class="thinborder">Delete</td>
  </tr>
<%double dGT = 0d; int iQty = 0; int iTotalQty = 0;
double dUnitPrice  = 0d;
double dTotalPrice = 0d;
boolean bolIsSelected = false;
for(int i = 0; i < vRetResult.size(); i += 21){
	dUnitPrice = Double.parseDouble(WI.getStrValue(vRetResult.elementAt(i + 9), "0"));
	iQty = Integer.parseInt((String)vRetResult.elementAt(i + 7));
	dTotalPrice = dUnitPrice * iQty;
	dGT += dTotalPrice;
	iTotalQty += iQty;

	if(vRetResult.elementAt(10).equals("1"))
		bolIsSelected = true;
	else
		bolIsSelected = false;
%>
  <tr>
    <td class="thinborder"><%=i/16 + 1%>.</td>
    <td height="20" class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
    <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
    <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
	<%
		strTemp = (String)vRetResult.elementAt(i + 2);
		if(strTemp != null)
			strTemp = (String)vRetResult.elementAt(i + 2);
		else
			strTemp = "";
	%>
    <td class="thinborder">&nbsp;<%=strTemp%></td>
    <td class="thinborder"><%=vRetResult.elementAt(i + 12)%></td>
    <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dUnitPrice, true)%> &nbsp;</td>
    <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTotalPrice, true)%>&nbsp;</td>
    <td class="thinborder"><%if(bolIsSelected && false){%>N/A<%}else{%><input name="submit22" type="submit" style="font-size:11px; height:18px;border: 1px solid #FF0000;" value="Edit" onClick="document.form_.preparedToEdit.value='1';document.form_.page_action.value='';document.form_.info_index.value='<%=vRetResult.elementAt(i)%>'"><%}%></td>
    <td class="thinborder"><%if(bolIsSelected){%>N/A<%}else{%><input name="submit22" type="submit" style="font-size:11px; height:18px;border: 1px solid #FF0000;" value="Delete" onClick="document.form_.page_action.value='0'; document.form_.info_index.value='<%=vRetResult.elementAt(i)%>'"><%}%></td>
  </tr>
<%}%>
  <tr>
    <td class="thinborder" align="right"><div align="left"><b>TOTAL : </b>&nbsp;</div></td>
    <td height="20" class="thinborder"><%=iTotalQty%></td>
    <td class="thinborder" align="center">&nbsp;</td>
    <td class="thinborder" align="center">&nbsp;</td>
    <td class="thinborder" align="center">&nbsp;</td>
    <td class="thinborder" align="center">&nbsp;</td>
    <td class="thinborder" align="center">&nbsp;</td>
    <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dGT, true)%>&nbsp;</td>
    <td colspan="2" align="center" class="thinborder">&nbsp;</td>
  </tr>
</table>
<%}//only if vRetResult is not null %>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25">&nbsp;</td>
    <td width="49%" valign="middle">&nbsp;</td>
    <td width="50%" valign="middle">&nbsp;</td>
  </tr>
  <tr bgcolor="#0D3371">
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>


<%=dbOP.constructAutoScrollHiddenField()%>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="setup_ref" value="<%=WI.fillTextValue("setup_ref")%>">
<%if(vBookInfo != null && vBookInfo.size() > 0) {%>
<input type="hidden" name="book_index" value="<%=vBookInfo.elementAt(0)%>">
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>