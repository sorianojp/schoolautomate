<%@ page language="java" import="utility.*, inventory.InventorySearch, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" SRC="../../../../jscript/td.js"></script>
<script language="javascript"  src ="../../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../../jscript/date-picker.js" ></script>
<script>
function SearchItemCode(){
	var pgLoc = "./search_registry.jsp?opner_info=form_.item_code";
	var win=window.open(pgLoc,"PrintWindow",'width=700,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchNow()
{
	document.form_.executeSearch.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function ReloadPage()
{
	document.form_.executeSearch.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}
</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./inv_dept_sheet_print.jsp" />
<% return;}
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-INVENTORY-INV_MAINT- View Inventory","inv_dept_sheet.jsp");
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

	Vector vRetResult = null;
	int iTemp = 0;
	int i = 0;
	double dTemp = 0d;
	String strCurCollege = null;
	String strCurDept = null;
	String strCollName = null;
	String strDeptName = null;
	boolean bolLooped = false;	
	
	InventorySearch InvSearch = new InventorySearch();
	if (WI.fillTextValue("executeSearch").equals("1")){
		vRetResult = InvSearch.viewInvSheetPerDept(dbOP,request);
	}
	if (vRetResult!= null && vRetResult.size() > 0){
		iSearchResult = InvSearch.getSearchCount();
	}else{
		strErrMsg = InvSearch.getErrMsg();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="inv_dept_sheet.jsp" method="post" >
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr bgcolor="#A49A6A"> 
				<td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
						INVENTORY MAINTENANCE - VIEW INVENTORY PAGE ::::</strong></font></div></td>
			</tr>
	</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3"><font size="3" color="red"><strong>
			<a href="control_sheet_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a>&nbsp;<%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
    
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">College</td>
			<%
					String strCIndex = WI.fillTextValue("c_index");
			%>
      <td width="80%"><select name="c_index" onChange="ReloadPage();">
        <option value="0">N/A</option>
        <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strCIndex, false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Department</td>
			<%
				String strDIndex = WI.fillTextValue("d_index");
			%>
      <td><select name="d_index">
        <% if(strCIndex != null && strCIndex.compareTo("0") != 0){%>
        <option value="">All</option>
        <%}else{%>
        <option value="0">Select Office</option>
        <%}%>
        <%if (strCIndex == null || strCIndex.length() == 0 || strCIndex.compareTo("0") == 0) 
						strCIndex = " and (c_index = 0 or c_index is null) ";
					else strCIndex = " and c_index = " +  strCIndex;
				%>
        <%=dbOP.loadCombo("d_index","d_NAME"," from department where is_del = 0 " + strCIndex + 
													" order by d_name asc",strDIndex, false)%>
      </select></td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:SearchNow();"><img src="../../../../images/form_proceed.gif"  border="0"></a></td>
    </tr>
    <tr> 
      <td height="18" colspan="3"><hr size="1"></td>
    </tr>
    
  <%if (vRetResult != null && vRetResult.size() > 0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a> 
          <font size="1">click to print list</font></div></td>
    </tr>
  <%}%>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="20" colspan="3" align="center" class="thinborder"><strong><font size="2">CONTROL SHEET PER OFFICE </font></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" class="thinborderBOTTOMLEFT"><font size="1"><strong>TOTAL 
        ITEMS: &nbsp;&nbsp;<%=iSearchResult%></strong></font> </td>
      <td width="32%" height="25" align="right" class="thinborderBOTTOMLEFT"><span class="thinborderBOTTOM">
    <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/InvSearch.defSearchSize;
		if(iSearchResult % InvSearch.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%>
Page
<select name="jumpto" onChange="SearchNow();">
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
    <tr>
      <td width="19%" align="center" class="thinborder"><strong><font size="1">ITEM CODE</font></strong></td>
      <td width="49%" height="22" align="center" class="thinborder"><font size="1"><strong>ITEM NAME </strong></font></td>
      <td align="center" class="thinborder"><strong><font size="1">AVAILABLE </font></strong></td>
    </tr>
    </tr>
    <% i = 0;
		for (; i < vRetResult.size();){
			bolLooped = false;
			strCollName = (String) vRetResult.elementAt(i+5);
			strDeptName = (String) vRetResult.elementAt(i+6);
		%>
		<tr>
      <td height="22" colspan="3" class="thinborder"><strong>&nbsp;<%=WI.getStrValue(strCollName,strDeptName)%></strong></td>
    </tr>    
    <%for (; i < vRetResult.size(); i+=9){
			  if(bolLooped){
				  if(!strCurCollege.equals((String) vRetResult.elementAt(i+7)) ||
						 !strCurDept.equals((String) vRetResult.elementAt(i+8))){
						break;
					}
				}
		%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td> 
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"")%><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;(",")","")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3),"")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+4),"")%></td>
    </tr>
    <%
			bolLooped = true;
			strCurCollege = (String) vRetResult.elementAt(i+7);
			strCurDept = (String) vRetResult.elementAt(i+8);
		}// inner for loop
		}// outer for loop%>
  </table>
  <%}// if (vRetResult != null && vRetResult.size() > 0)%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3"><div align="center"></div></td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="inventory_type" value="<%=WI.fillTextValue("inventory_type")%>">
	<input type="hidden" name="executeSearch" value="<%=WI.fillTextValue("executeSearch")%>">
  <input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>