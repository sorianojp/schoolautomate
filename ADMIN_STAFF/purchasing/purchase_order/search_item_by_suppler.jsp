<%@ page language="java" import="utility.*,purchasing.PO,purchasing.Requisition,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements())
		strFormName = strToken.nextToken();		
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage(){	
    document.form_.printPage.value = "";	
 	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}

</script>
<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;

	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="./search_item_by_suppler_print.jsp"/>
	<%}
 	
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-PURCHASE ORDER"),"0"));
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
								"Admin/staff-PURCHASING-PURCHASE ORDER-Approved Requests","search_item_by_suppler.jsp");
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
		
	Requisition REQ = new Requisition();
	PO PO = new PO();
	Vector vRetResult = null;
	Vector vPOItems = null;	
	int iSearch = 0;
	int iDefault = 0;
	boolean bolLooped = false;
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"Supplier","Frequency", "Item"};
	String[] astrSortByVal     = {"SUPPLIER_CODE","frequency","item_name"};		
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vRetResult = PO.searchItemBySupplier(dbOP,request);
		if(vRetResult == null)
			strErrMsg = PO.getErrMsg();
		else
			iSearch = PO.getSearchCount();
	}
	
%>
<form name="form_" method="post" action="search_item_by_suppler.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PURCHASE </strong></font><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>ORDER</strong></font><font color="#FFFFFF"><strong> 
          - VIEW/SEARCH PO PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(false){%>
    <!--
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="21%">College :</td>
      <td width="77%"><select name="c_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%if(WI.fillTextValue("c_index").equals("0")){%>
          <option value="0" selected>Non-Academic Office</option>
          <%}else{%>
          <option value="0">Non-Academic Office</option>
          <%} 
			if(WI.fillTextValue("c_index").length() > 0)
				strTemp = WI.fillTextValue("c_index");
			else
				strTemp = "0";
			
			if(strTemp.compareTo("0") ==0)
				strTemp2 = "Offices";
			else
			strTemp2 = "Department";
			%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td><%=strTemp2%></td>
      <td> <%String strTemp3 = null;
		if(strTemp.compareTo("0") ==0) //only if non college show others.
			strTemp2 = " onChange='ShowHideOthers(\"d_index\",\"oth_dept\",\"dept_\");'";
		else
			strTemp2 = "";
	  %> <select name="d_index">
          <option value="">All</option>
          <%if(WI.fillTextValue("c_index").length() < 1)
				strTemp = "-1";
			else
				strTemp3 = WI.fillTextValue("d_index");
		%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and ("+WI.getStrValue(strTemp, "c_index=",""," c_index = 0 or c_index is null")+") order by d_name asc",strTemp3, false)%> </select></td>
    </tr>
	-->
    <%}%>
    <tr> 
      <td width="3%" height="27">&nbsp;</td>
      <td width="15%">Supplier :</td>
      <td width="82%"> <%if(WI.fillTextValue("supplier").length() > 0)
	  		strTemp = WI.fillTextValue("supplier");
		else
			strTemp = "";%> <select name="supplier">
          <option value="">All</option>
          <%=dbOP.loadCombo("PROFILE_INDEX","SUPPLIER_CODE"," from PUR_SUPPLIER_PROFILE " +
		  "where is_del = 0 order by SUPPLIER_CODE asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td>Item :</td>
      <td> <%if(WI.fillTextValue("item").length() > 0)
	  		strTemp = WI.fillTextValue("item");
		else
			strTemp = "";%> <select name="item" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("ITEM_INDEX","ITEM_NAME"," from PUR_PRELOAD_ITEM order by ITEM_NAME asc", strTemp, false)%> </select></td>
    </tr>
	<%if(WI.fillTextValue("item").length() > 0){%>
    <tr> 
      <td height="27">&nbsp;</td>
      <td>Brand :</td>
      <td> <%strTemp = WI.fillTextValue("brand");%> 
	    <select name="brand">
         <option value="">All</option>
           <%=dbOP.loadCombo("brand_index","brand_name"," from pur_preload_brand order by brand_name asc", strTemp, false)%> 
 	    </select>
	  </td>
    </tr>
	<%}%>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="19">&nbsp;</td>
      <td width="745"><strong>Sort</strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td><select name="sort_by1">
        <option value="">N/A</option>
        <%=PO.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td><select name="sort_by1_con">
        <option value="asc">Ascending</option>
        <%
			if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="21" height="26">&nbsp;</td>
      <td><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0" ></a>      </td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<%if(!(WI.fillTextValue("opner_info").length() > 0)){%>
    <tr> 
      <td height="28" colspan="2"><div align="right">Number of Items Per Page: 
          <select name="num_stud_page">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"20"));
				for(int i = 10; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPage();"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1"> click to print list&nbsp;</font></div></td>
    </tr>
	<%}%>
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr> 
      <td height="10">
	  	<strong><font size="1">TOTAL RESULT : <%=iSearch%>- Showing(<%=PO.getDisplayRange()%>)</font></strong>
     <%
		int iPageCount = iSearch/PO.defSearchSize;
		if(iSearch % PO.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%>
		&nbsp;</td>
		
      <td> <div align="right">Jump to page: 
          <select name="jumpto" onChange="ProceedClicked();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
				}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
    <tr>
      <td width="100%" height="25" bgcolor="#B9B292" colspan="2" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF PURCHASED ITEM(S) PER SUPPLIER</strong></font></div></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="23%" height="27" rowspan="2" class="thinborder"><div align="center"><strong>SUPPLIER</strong></div></td>
      <td width="51%" rowspan="2" class="thinborder"><div align="center"><strong>ITEM 
          / BRAND</strong></div></td>
      <td width="9%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">FREQUENCY</font></strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong><font size="1">LAST PURCHASE</font></strong></div></td>
    </tr>
    <tr>
      <td width="9%" class="thinborder"><div align="center"><strong><font size="1">PRICE</font></strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">DATE</font></strong></div></td>
    </tr>
    <% 
	for(int iLoop = 0;iLoop < vRetResult.size();iLoop+=8){
	%>
    <tr> 
      <td height="22" valign="top" class="thinborder"><div align="left"><font size="1"> 
          &nbsp; 
          <%
		  if (bolLooped && ((String)vRetResult.elementAt(iLoop)).equals((String)vRetResult.elementAt(iLoop-8))){%>
          &nbsp; 
          <%}else{%>
          <%=(String)vRetResult.elementAt(iLoop)%> 
          <%}%>
          </font></div></td>
      <td valign="top" class="thinborder">&nbsp; <%=(String)vRetResult.elementAt(iLoop+2)%><%=WI.getStrValue((String)vRetResult.elementAt(iLoop+1),"(",")","&nbsp;")%></td>
	  <td valign="top" class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(iLoop+6)%>&nbsp;</div></td>
	  <td valign="top" class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(iLoop+7)%>&nbsp;</div></td>
      <td valign="top" class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(iLoop+3)%>&nbsp;</div></td>
    </tr>
    <%
		bolLooped = true;
	}%>
  </table>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
  </table>
  <%}%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="18" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="isForPO" value="1">
  <input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
  <input type="hidden" name="status" value="1">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>