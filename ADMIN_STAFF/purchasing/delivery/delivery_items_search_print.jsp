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
<body bgcolor="#FFFFFF" onLoad="javascript:window.print()">
<%@ page language="java" import="utility.*,purchasing.Delivery,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-DELIVERY"),"0"));
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
								"Admin/staff-PURCHASING-DELIVERY-Print delivery search","delivery_view_search_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	Delivery DEL = new Delivery();
	Vector vRetResult = null;
	String[] astrPOStatus = {"Disapproved","Approved","Pending"};
 	String[] astrPORecStatus = {"Not Received","Received (All)","Received (Partial)"};
	String strInvoice = null;
	String strDateReceived = null;
	String strTotalItem = null;
	String strTotal = null;
	String strTemp  = null;
	double dQty = 0d;
	double dTotalAmount = 0d;
	double dTemp = 0d;
	
	int iSearch = 0;
	int iDefault = 0;
	int i = 0;
	int iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
	boolean bolPageBreak = false;
	boolean bolLooped = false;
	boolean bolMoreThanOne = false;
	boolean bolShowTotal = false;
	int iPage = 1;
	int iTotalPage = 0;
	int iItems = 8; // the number of elements in the vRetResult vector
	
	vRetResult = DEL.searchDeliveriesBySupplier(dbOP,request);

	if(vRetResult != null ){
	int iIncr = 1;
	int iPageCount = vRetResult.size()/(iItems*iMaxStudPerPage);		
	if(vRetResult.size() % (iItems*iMaxStudPerPage) > 0) ++iPageCount;		
	for(;i < vRetResult.size();iPage++){
	bolLooped = false;	
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
   <br> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="31%" height="26"><div align="right">Page <%=iPage%> of <%=iPageCount%></div></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr> 
      <td  height="25" colspan="5" class="thinborder"><div align="center"><strong>LIST 
          OF ITEM DELIVERIES PER SUPPLIER </strong></div></td>
    </tr>
	<!--
    <tr> 
      <td colspan="8" class="thinborder"><strong>TOTAL INVOICES 
        : <%=iSearch%></strong></td>
    </tr>
	-->
    <tr> 
      <td width="26%" height="24" class="thinborder"><div align="center"><strong>SUPPLIER </strong></div></td>
      <td width="37%" class="thinborder"><div align="center"><strong>ITEM / BRAND </strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>QTY / UNIT </strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>UNIT PRICE </strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong>TOTAL AMOUNT </strong></div></td>
    </tr>
    <% 
 	for(int iCount = 0; iCount <= iMaxStudPerPage; i += iItems,++iCount,iIncr++){
  	if (iCount >= iMaxStudPerPage || i >= vRetResult.size()){
			if(i >= vRetResult.size())
				bolPageBreak = false;
			else				
				bolPageBreak = true;
			break;			
	 	}		
		if(bolLooped){
		  if(((String)vRetResult.elementAt(i)).equals((String)vRetResult.elementAt(i-iItems))){
			bolMoreThanOne = true;
		  }else{
			dQty = 0d;
			dTotalAmount = 0d;
		  }
		}
		
		if((bolLooped && (i+iItems) < vRetResult.size() && 
		  !((String)vRetResult.elementAt(i)).equals((String)vRetResult.elementAt(i+iItems)))  || i + iItems >= vRetResult.size() 
		  || (i > 0 && !((String)vRetResult.elementAt(i)).equals((String)vRetResult.elementAt(i+iItems)) )){
//		   || iCount+1 >= iMaxStudPerPage - para mo butang total pag mag next page
			if(bolMoreThanOne){
				bolShowTotal = true;
				bolMoreThanOne = false;
			}
		}
	%>
    <tr> 
      <td height="25" class="thinborder"><div align="left">&nbsp;	  	
        <%if (bolLooped && ((String)vRetResult.elementAt(i)).equals((String)vRetResult.elementAt(i-iItems))){%>
		&nbsp;
		<%}else{%>
		<%=(String)vRetResult.elementAt(i+1)%>
		<%}%>
      </div></td>		  
      <td class="thinborder"><div align="left">&nbsp;<%=(String)vRetResult.elementAt(i+2)%><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"/","","")%></div></td>
	  <% dTemp = 0d;
	  	strTemp = (String)vRetResult.elementAt(i+4);
		strTemp = ConversionTable.replaceString(strTemp, ",","");
		dTemp = Double.parseDouble(strTemp);
		dQty += dTemp;
	  %>
      <td class="thinborder"><div align="right"><%=strTemp%>&nbsp;<%=(String)vRetResult.elementAt(i+5)%>&nbsp;</div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true)%>&nbsp;</div></td>
	  <% dTemp = 0d;
	  	strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+7),true);
		dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
		dTotalAmount += dTemp;
	  %>	  
      <td class="thinborder"><div align="right"><%=strTemp%>&nbsp;</div></td>
    </tr>
	<%if(bolShowTotal){
		bolShowTotal = false;
		iIncr = 0;
	%>
	<tr> 
      <td height="21" colspan="2" class="thinborder" ><div align="right"><strong>TOTAL : &nbsp;</strong></div></td>
      <!--<td class="thinborder" ><div align="right"><strong><%//=CommonUtil.formatFloat(dQty,true)%>&nbsp;</strong></div></td>-->
	  <td class="thinborder" >&nbsp;</td>	  
      <td class="thinborder" >&nbsp;</td>
      <td class="thinborder" ><div align="right"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%></strong>&nbsp;</div></td>
	</tr>
	<tr>
	  <td colspan="5" class="thinborder" >&nbsp;</td>
    </tr>
	<%dQty = 0d;
	dTotalAmount = 0d;
	}%>	
    <%bolLooped = true;
	}%>		
   <%if (i >= vRetResult.size()){	
   %>
    <tr> 
      <td class="thinborder" colspan="5" ><div align="center"> ~~~~~NOTHING 
          FOLLOWS ~~~~~ </div></td>
    </tr>
    <%}else{%>
    <tr> 
      <td class="thinborder" colspan="5" ><div align="center"> ~~~CONTINUED ON NEXT PAGE ~~~ </div></td>
    </tr>
    <%}%>
  </table>
  <%
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
    if (bolPageBreak) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
