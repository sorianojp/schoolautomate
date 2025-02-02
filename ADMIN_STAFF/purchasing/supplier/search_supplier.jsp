<%@ page language="java" import="utility.*, purchasing.Supplier, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);

	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();
	
	}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
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
<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopySupplierCode(strPropNum)
{
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strPropNum;
	window.opener.focus();
	<%
	if(strFormName != null){%>
	window.opener.document.<%=strFormName%>.submit();
	<%}%>
	self.close();
}
<%}%>

</script>

<%  DBOperation dbOP = null;
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-SUPPLIERS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
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

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-SUPPLIERS-Search Supplier","search_supplier.jsp");
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
	int i = 0;
	int iTemp = 0;
	String strErrMsg = null;

	int iSearchResult = 0;

	Supplier SUP = new Supplier();

	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrStatus   = {"Inactive", "Active"};
	String[] astrType   = {"Individual", "Company"};
	String strTemp  = null;
	
	if(WI.fillTextValue("executeSearch").compareTo("1") == 0){
	vRetResult = SUP.searchSupplier(dbOP, request);
	if(vRetResult == null)
		strErrMsg = SUP.getErrMsg();
	else	
		iSearchResult = SUP.getSearchCount();
}
	
%>

<body bgcolor="#D2AE72">
<form action="./search_supplier.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY: PROPERTY SEARCH PAGE::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td colspan="4" height="20"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
	</table>
	  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="14%">Supplier Type</td>
      <td colspan="2"><%strTemp = WI.fillTextValue("supplier_type");%> <select name="supplier_type">
          <option value="">N/A</option>
          <%if (strTemp.equals("0")){%>
          <option value="0" selected>Individual</option>
          <%} else {%>
          <option value="0">Individual</option>
          <%} if (strTemp.equals("1")) {%>
          <option value="1" selected>Company</option>
          <%} else {%>
          <option value="1">Company</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Supplier Code</td>
      <td width="17%"> <select name="supplier_code_con">
          <%=SUP.constructGenericDropList(WI.fillTextValue("supplier_code_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td width="67%"> <input type="text" name="supplier_code" value="<%=WI.fillTextValue("supplier_code")%>" class="textbox"
	  	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Supplier Name</td>
      <td><select name="supplier_name_con">
          <%=SUP.constructGenericDropList(WI.fillTextValue("supplier_name_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select></td>
      <td><input type="text" name="supplier_name" value="<%=WI.fillTextValue("supplier_name")%>" class="textbox"
	  	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Status</td>
      <td> <%strTemp = WI.fillTextValue("status");%> <select name="status">
          <option value="">N/A</option>
          <%if (strTemp.equals("0")){%>
          <option value="0" selected>Inactive</option>
          <%} else {%>
          <option value="0">Inactive</option>
          <%} if (strTemp.equals("1")) {%>
          <option value="1" selected>Active</option>
          <%} else {%>
          <option value="1">Active</option>
          <%}%>
        </select></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="24%">&nbsp;</td>
      <td width="25%"><a href="javascript:SearchNow();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td width="27%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <% if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="25" colspan="4" class="thinborder"><div align="center"><font color="#FFFFFF"><strong> 
          INVENTORY REPORT </strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" class="thinborder"><strong><font size="1"> TOTAL 
        ITEM(S) : <%=iSearchResult%> - Showing(<%=SUP.getDisplayRange()%>)</font></strong></td>
      <td height="25" align="right" class="thinborder"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/SUP.defSearchSize;
		if(iSearchResult % SUP.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>
        Jump To page: 
        <select name="jumpto" onChange="SearchNow();">
          <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
          <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%	}
			}
			%>
        </select> <%} else {%> &nbsp; <%}%></td>
    </tr>
    <tr> 
      <td width="16%" class="thinborder" align="center" height="25"><font size="1"><strong>SUPPLIER 
        NAME </strong></font></td>
      <td width="10%" class="thinborder" align="center"><font size="1"><strong>SUPPLIER 
        CODE </strong></font></td>
      <td width="16%" class="thinborder" align="center"><font size="1"><strong>STATUS</strong></font></td>
      <td width="10%" class="thinborder" align="center"><font size="1">&nbsp;<strong>TYPE</strong></font></td>
    </tr>
    <%for (i = 0; i<vRetResult.size(); i+=4){%>
    <tr> 
      <td class="thinborder" align="center"><font size="1">&nbsp; <%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td class="thinborder"><font size="1">&nbsp; 
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href='javascript:CopySupplierCode("<%=(String)vRetResult.elementAt(i+2)%>");'> 
        <%=(String)vRetResult.elementAt(i+2)%></a> 
        <%}else{%>
        <%=(String)vRetResult.elementAt(i+2)%> 
        <%}%>
        </font></td>
      <td height="25" class="thinborder"><font size="1">&nbsp; <%=astrStatus[Integer.parseInt((String)vRetResult.elementAt(i+1))]%></font></td>
      <td class="thinborder"><font size="1"><%=astrType[Integer.parseInt((String)vRetResult.elementAt(i))]%></font></td>
    </tr>
    <%}%>
  </table>
  <%}// end if vRetResult != null%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <input type="hidden" name="executeSearch" value="<%=WI.fillTextValue("executeSearch")%>">
  <input type="hidden" name="print_pg">

  <!-- Instruction -- set the opner_from_name to the parent window to copy stuff -->
	<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
