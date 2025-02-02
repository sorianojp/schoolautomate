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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
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
		<jsp:forward page="./purchase_logged_PO_print.jsp"/>
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
	String[] astrSortByName    = {"Supplier","Item"};
	String[] astrSortByVal     = {"SUPPLIER_CODE","item_index"};		
	
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
      <td height="27">&nbsp;</td>
      <td>Supplier :</td>
      <td> <%if(WI.fillTextValue("supplier").length() > 0)
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
			strTemp = "";%> <select name="item">
          <option value="">All</option>
          <%=dbOP.loadCombo("ITEM_INDEX","ITEM_NAME"," from PUR_PRELOAD_ITEM order by ITEM_NAME asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td>PO Date</td>
      <td> <%strTemp = WI.fillTextValue("po_date_fr");%> <input name="po_date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.po_date_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <%strTemp = WI.fillTextValue("po_date_to");%> <input name="po_date_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.po_date_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      </td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="13" height="26">&nbsp;</td>
      <td width="1492"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0" ></a> 
      </td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<%if(!(WI.fillTextValue("opner_info").length() > 0)){%>
    <tr> 
      <td height="28" colspan="2"><div align="right">Number of PO(s) Per Page: 
          <select name="num_stud_page">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"20"));
				for(int i = 5; i <=30 ; i++) {
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
		double dTotalItems = 0d;
		double dTotalAmount = 0d;
		if(iSearch % PO.defSearchSize > 0) ++iPageCount;		
		if(iPageCount >= 1)
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
          OF PURCHASE ORDER(S)</strong></font></div></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="7%" height="25" class="thinborder"><div align="center"><font size="1"><strong>PO 
          DATE</strong></font></div></td>
      <td width="12%" class="thinborder"><strong>PO NO.</strong></td>
      <td width="12%" class="thinborder"><strong>SUPPLIER</strong></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>REQUESTING 
          DEPARTMENT </strong></font></div></td>
      <td width="36%" class="thinborder"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>UNIT 
          PRICE</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong><strong>TOTAL 
          PRICE</strong></strong></font></div></td>
    </tr>
    <% 
	for(int iLoop = 0;iLoop < vRetResult.size();iLoop+=8){
	%>
    <tr> 
      <td height="25" valign="top" class="thinborder"><div align="right"><font size="1"> 
          <%if (bolLooped && ((String)vRetResult.elementAt(iLoop + 3)).equals((String)vRetResult.elementAt(iLoop-5))){%>
          &nbsp; 
          <%}else{%>
          <%=(String)vRetResult.elementAt(iLoop+3)%> 
          <%}%>
          </font></div></td>
      <td valign="top" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(iLoop+5)%></font></td>
      <td valign="top" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(iLoop+4)%></font></td>
      <td valign="top" class="thinborder"> <div align="left"> <font size="1"> 
          <%if(((String)vRetResult.elementAt(iLoop+1)) != null){%>
          <%=WI.getStrValue((String)vRetResult.elementAt(iLoop+1),"") +"/"+ WI.getStrValue((String)vRetResult.elementAt(iLoop+2),"All")%> 
          <%}else{%>
          <%=WI.getStrValue((String)vRetResult.elementAt(iLoop+2),"&nbsp;")%> 
          <%}%>
          </font></div></td>
      <td colspan="3" valign="top" class="thinborder">&nbsp; </td>
      <%if ( vPOItems != null && vPOItems.size() > 0){
	 	 if (vPOItems.elementAt(4)!= null){
		    strTemp = (String) vPOItems.elementAt(4);
		 }else
			strTemp = ""; 
	   }else
		strTemp = "";
	 %>
      <%if ( vPOItems != null && vPOItems.size() > 0){
	 	 if (vPOItems.elementAt(5)!= null){
		    strTemp = (String) vPOItems.elementAt(5);
		 }else
			strTemp = ""; 
	   }else
		strTemp = "";
	 %>
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