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
<style>
TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
}
TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<body onLoad="window.print()">
<%	
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
								"PURCHASING-QUOTATION","quotation_view_search_print.jsp");
								
	Quotation QTN = new Quotation();	
	Vector vRetResult = null;	
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"PO No.","Supplier"};
	String[] astrSortByVal     = {"PO_NUMBER","SUPPLIER_CODE"};
	String strErrMsg = null;
	String[] astrQuoteUnit = {"(Per Unit)","(Whole Order)"};   
	int iSearch = 0;
	int iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
	int iLoop = 0;
	boolean bolPageBreak = false;
	
	vRetResult = QTN.operateOnSearchList(dbOP,request);
	if(vRetResult == null)
		strErrMsg = QTN.getErrMsg();
	else
		iSearch = QTN.getSearchCount();
		
	if(vRetResult != null){
	for(;iLoop < vRetResult.size();){	
%>
<form name="form_" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">        
	<tr> 
    <td height="25" colspan="2"><div align="center"> 
            <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
        </div></td>
  </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="20%"><font size="1">Canvassing No.</font></td>
      <td width="26%"><strong><font size="1">	  
	  <%if(WI.fillTextValue("po_no_select").equals("equals")){%>
	  <%=WI.getStrValue(WI.fillTextValue("po_no"),"-")%>
	  <%}else if(WI.fillTextValue("po_no_select").equals("contains")){%>
	  <%=WI.fillTextValue("po_no_select") +" - "+ WI.getStrValue(WI.fillTextValue("po_no"),"-")%>
	  <%}else{%>
	  <%=WI.fillTextValue("po_no_select") +" with - "+ WI.getStrValue(WI.fillTextValue("po_no"),"-")%>
	  <%}%>	  
	  </font></strong></td>
      <td width="20%"><font size="1">Supplier</font></td>
      <td width="31%"><strong><font size="1">
	  <%=WI.getStrValue(dbOP.mapOneToOther("PUR_SUPPLIER_PROFILE","PROFILE_INDEX",WI.fillTextValue("supplier"),"SUPPLIER_NAME"," and IS_DEL = 0"),"All")%>
	  </font></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">Particulars/Item Desc.</font></td>
      <td><strong><font size="1">
	  <%if(WI.fillTextValue("particular_select").equals("equals")){%>
	  <%=WI.getStrValue(WI.fillTextValue("particular"),"-")%>
	  <%}else if(WI.fillTextValue("particular_select").equals("contains")){%>
	  <%=WI.fillTextValue("particular_select") +" - "+ WI.getStrValue(WI.fillTextValue("particular"),"-")%>
	  <%}else{%>
	  <%=WI.fillTextValue("particular_select") +" with - "+ WI.getStrValue(WI.fillTextValue("particular"),"-")%>
	  <%}%>	  
	  </font></strong></td>
      <td><font size="1">Item</font></td>
      <td><strong><font size="1">	  
	  <%=WI.getStrValue(dbOP.mapOneToOther("PUR_PRELOAD_ITEM","ITEM_INDEX",WI.fillTextValue("item"),"ITEM_NAME",""),"All")%>
	  </font></strong></td>
    </tr>   
  </table>
<%if(vRetResult != null && vRetResult.size() > 3){%> 
  <table width="100%" border="0" class="thinborder" cellpadding="1" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="8" class="thinborder"><div align="center"><strong>LIST 
          OF QUOTATION(S)</strong></div></td>
    </tr>
    <tr> 
      <td width="4%" height="20" class="thinborder"><div align="center"><font size="1"><strong>ITEM#</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>CANVASSING 
          NO. </strong></font></div></td>
      <td width="17%" class="thinborder"><div align="center"><font size="1"><strong>ITEM/PARTICULARS/DESCRIPTION 
          </strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>BRAND 
          NAME</strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>SUPPLIER 
          CODE </strong></font></div></td>
      <td width="17%" class="thinborder"><div align="center"><font size="1"><strong> 
          PRICE QUOTED</strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>DISCOUNT</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>FINAL 
          PRICE QUOTED</strong></font></div></td>
    </tr>
    <% 
 	for(int iCount = 0; iCount <= iMaxStudPerPage; iLoop += 11,++iCount){	
  		if (iCount >= iMaxStudPerPage || iLoop >= vRetResult.size()){
			if(iLoop >= vRetResult.size())
				bolPageBreak = false;
			else
				bolPageBreak = true;
			break;			
	 }%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(iLoop+11)/11%></div></td>
      <td class="thinborder"><div align="center"><%=vRetResult.elementAt(iLoop)%></div></td>
      <td class="thinborder"><div align="left"><%=vRetResult.elementAt(iLoop+1)%> 
          / <%=vRetResult.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(iLoop+10),"&nbsp;")%></td>
      <td class="thinborder"><div align="center"><%=vRetResult.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(iLoop+4)),true) + 
	                                               astrQuoteUnit[Integer.parseInt((String)vRetResult.elementAt(iLoop+8))]%></div></td>
      <td class="thinborder"><div align="right"> 
          <%if(((String)vRetResult.elementAt(iLoop+6)).equals("1")){%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(iLoop+5)),false)%>% 
          <%}else{%>
          <%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(iLoop+5)),true)+
			  astrQuoteUnit[Integer.parseInt((String)vRetResult.elementAt(iLoop+9))]%> 
          <%}%>
        </div></td>
      <td class="thinborder"><div align="right"> <%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(iLoop+7)),true)%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="8" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=iSearch%></strong></div></td>
    </tr>
    <%if (iLoop >= vRetResult.size()){%>
    <tr> 
      <td  class="thinborder" colspan="9" ><div align="center"> *****************NOTHING 
          FOLLOWS *******************</div></td>
    </tr>
    <%}else{%>
    <tr> 
      <td  class="thinborder" colspan="9" ><div align="center"> ************** 
          CONTINUED ON NEXT PAGE ****************</div></td>
    </tr>
    <%}%>
  </table>
  <%
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
    if (bolPageBreak) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }}}%>
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
