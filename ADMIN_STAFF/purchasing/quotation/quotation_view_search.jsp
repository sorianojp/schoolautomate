<%@ page language="java" import="utility.*,purchasing.Quotation,java.util.Vector" %>
<%	
	WebInterface WI = new WebInterface(request);
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
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#D2AE72">
<%
	if(WI.fillTextValue("printPage").equals("1")){%>	
		<jsp:forward page="./quotation_view_search_print.jsp"/>
	<%}
		
     //authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-QUOTATION"),"0"));
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
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"PURCHASING-QUOTATION","quotation_view_search.jsp");
								
	Quotation QTN = new Quotation();	
	Vector vRetResult = null;	
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"Canvassing No.","Supplier"};
	String[] astrSortByVal     = {"CANVASS_NO","SUPPLIER_CODE"};
	String[] astrQuoteUnit = {"(per unit)","(whole order)"};
	String strErrMsg = null;
	String strTemp = null;
	
	int iSearch = 0;
	int iDefault = 0;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vRetResult = QTN.operateOnSearchList(dbOP,request);
		if(vRetResult == null)
			strErrMsg = QTN.getErrMsg();
		else
			iSearch = QTN.getSearchCount();	
	}		
%>
<form name="form_" method="post" action="./quotation_view_search.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          QUOTATION - SEARCH/VIEW QUOTATIONS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="0%" height="25">&nbsp;</td>
      <td width="21%" height="25">Canvassing No. : </td>
      <td width="35%" height="25"> <select name="po_no_select">
          <%=QTN.constructGenericDropList(WI.fillTextValue("po_no_select"),astrDropListEqual,astrDropListValEqual)%> 
		  </select> <input type="text" name="po_no" class="textbox" value="<%=WI.fillTextValue("po_no")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="11%" height="25">Supplier :</td>
      <td width="30%" height="25"> 
	  <%if(WI.fillTextValue("supplier").length() > 0)
	  		strTemp = WI.fillTextValue("supplier");
		else
			strTemp = "";%>
		<select name="supplier">
          <option value="">All</option>
          <%=dbOP.loadCombo("PROFILE_INDEX","SUPPLIER_CODE"," from PUR_SUPPLIER_PROFILE " +
		  "where is_del = 0 order by SUPPLIER_CODE asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Particulars/Item Desc. :</td>
      <td height="25"><select name="particular_select">
          <%=QTN.constructGenericDropList(WI.fillTextValue("particular_select"),astrDropListEqual,astrDropListValEqual)%> 
		  </select> <input type="text" name="particular" class="textbox" value="<%=WI.fillTextValue("particular")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td height="25">Item :</td>
      <td height="25">
	  <%if(WI.fillTextValue("item").length() > 0)
	  		strTemp = WI.fillTextValue("item");
		else
			strTemp = "";%> 
		<select name="item">
          <option value="">All</option>
          <%=dbOP.loadCombo("ITEM_INDEX","ITEM_NAME"," from PUR_PRELOAD_ITEM order by ITEM_NAME asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="3"><strong>Sort</strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td width="24%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=QTN.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="32%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=QTN.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="41%">&nbsp;</td>
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
        </select> </td>
      <td><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="26" colspan="4">&nbsp; </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="3">
	  <a href="javascript:ProceedClicked();">
	  <img src="../../../images/form_proceed.gif" border="0" ></a> 
      </td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 3){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
    <tr> 
      <td height="28" colspan="2"><div align="right">Number of Quotations Per 
          Page: 
          <select name="num_stud_page">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"20"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
	  <a href="javascript:PrintPage();">
	  <img src="../../../images/print.gif" border="0"></a>
	  <font size="1"> 
          click to print list</font></div></td>
    <tr> 
      <td height="10">
	  	<strong><font size="1">TOTAL RESULT : <%=iSearch%>- Showing(<%=QTN.getDisplayRange()%>)</font></strong>
     <%
		int iPageCount = iSearch/QTN.defSearchSize;
		double dTotalItems = 0d;
		double dTotalAmount = 0d;
		if(iSearch % QTN.defSearchSize > 0) ++iPageCount;		
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
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF QUOTATION(S)</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="14%" height="25" class="thinborder"><div align="center"><font size="1"><strong>CANVASSING 
          NO.</strong></font></font></div></td>
      <td width="26%" class="thinborder"><div align="center"><font size="1"><strong>ITEM/PARTICULARS/DESCRIPTION</strong></font></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>BRAND 
          NAME</strong> </font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>SUPPLIER 
          CODE</strong></font> </font></div></td>
      <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>PRICE 
          QUOTED</strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>DISCOUNT</strong></font></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>FINAL 
          PRICE QUOTED</strong></font></font></div></td>
    </tr>
    <%for(int iLoop = 0;iLoop < vRetResult.size();iLoop+=11){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=vRetResult.elementAt(iLoop)%></div></td>
      <td class="thinborder"><div align="left"><%=vRetResult.elementAt(iLoop+1)%> 
          / <%=vRetResult.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(iLoop+10),"&nbsp;")%></td>
      <td class="thinborder"><div align="center"><%=vRetResult.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(iLoop+4)),true) + 
	                                               astrQuoteUnit[Integer.parseInt((String)vRetResult.elementAt(iLoop+8))]%></div></td>
      <td class="thinborder"><div align="right"> 
          <%if(((String)vRetResult.elementAt(iLoop+6)).equals("1")){%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(iLoop+5)),false)%>%&nbsp; 
          <%}else{%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(iLoop+5)),true)+
		     astrQuoteUnit[Integer.parseInt((String)vRetResult.elementAt(iLoop+9))]%>&nbsp; 
          <%}%>
        </div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(iLoop+7)),true)%></font></div></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
 <%}%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="printPage" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
